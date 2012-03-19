require 'optparse'
require 'json'
require 'httparty'
require 'date'
require 'active_model'
require 'active_support/inflector'

module NeoScout

  class Main
    attr_reader :opt_db
    attr_reader :opt_schema
    attr_reader :opt_port
    attr_reader :opt_webservice
    attr_reader :opt_bind
    attr_reader :opt_report
    attr_reader :opt_no_nodes
    attr_reader :opt_no_edges
    attr_reader :opt_type_mapper
    attr_reader :opt_pre_mapper
    attr_reader :opt_output_file


    def initialize
      @opt_report      = 0
      @opt_webservice  = false
      @opt_output_file = nil
      @opt_no_nodes    = false
      @opt_no_edges    = false
      @opt_pre_mapper  = lambda { |t| t }
      @opt_type_mapper = lambda { |t| t }
      parse_opts
    end

    def parse_opts
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: --db <neo4j:path> --schema <url> [--port <port>]"
        opts.on('-d', '--db DB', 'Path to database in the form neo4j:<path>)') do |db|
          @opt_db     = db
        end
        opts.on('-u', '--schema-url URL', 'URL to database schema') do |url|
          @opt_schema = lambda { || ::JSON.parse(HTTParty.get(url)) }
        end
        opts.on('-s', '--schema-file FILE', 'schema file') do |file|
          @opt_schema = lambda { || ::JSON.parse(IO::read(file)) }
        end
        opts.on('-o', '--output-file FILE', 'output file in standalone mode') do |f|
          @opt_output_file = f
        end
        opts.on('-w', '--webservice', 'Run inside sinatra') do
          @opt_webservice = true
        end
        opts.on('-p', '--port PORT', 'Port to be used') do |port|
          @opt_port   = port.to_i
        end
        opts.on('-b', '--bind ITF', 'Interface to be used') do |itf|
          @port       = itf
        end
        opts.on('-r', '--report NUM', 'Report progress every NUM graph elements') do |num|
          @opt_report = num.to_i
        end
        opts.on('--no-nodes', 'Do not iterate over nodes') do
          @opt_no_nodes = true
        end
        opts.on('--no-edges', 'Do not iterate over edges') do
          @opt_no_edges = true
        end
        opts.on('-P', '--pluralize-types', 'Pluralize type names') do
          @opt_pre_mapper = lambda { |t| t.pluralize }
        end
        opts.on('-S', '--singularize-types', 'Singularize type names') do
          @opt_pre_mapper = lambda { |t| t.singularize }
        end
        opts.on('-M', '--type-mapper MAPPER',
                'Set the type mapper (underscore, downcase, upcase)') do |mapper|
          @opt_type_mapper = case mapper
                               when 'underscore'
                                 lambda { |t| t.underscore }
                               when 'downcase'
                                 lambda { |t| t.downcase }
                               when 'upcase'
                                 lambda { |t| t.upcase }
                               else
                                 raise ArgumentException('Unsupported mapper')
                             end
        end
        opts.on('-h', '--help', 'Display this screen') do
          puts opts
          exit 1
        end
      end
      optparse.parse!
      @opt_output_file = nil if @opt_webservice
    end

    def start_db
      @opt_db.match(/(neo4j:)(.*)/) do |m|
        Neo4j.config[:storage_path] = m[2] unless (m[2].length == 0)
        Neo4j.start
        return lambda do
          scout = ::NeoScout::GDB_Neo4j::Scout.new
          pre_mapper = self.opt_pre_mapper
          scout.typer.node_mapper = lambda { |t| self.opt_type_mapper(pre_mapper.call(t)) }
          scout.typer.edge_mapper = lambda { |t| self.opt_type_mapper(pre_mapper.call(t)) }
          scout
        end
      end

      raise ArgumentError("Unsupported database type")
    end

    def shutdown_db
      @opt_db.match(/(neo4j:)(.*)/) do |m|
        Neo4j.shutdown
        return
      end

      raise ArgumentError("Unsupported database type")
    end

    class SimpleConsoleLogger
      def method_missing(key, *args)
        print key
        print ': '
        puts *args
      end
    end

    def run
      ### Load schema at least once to know that we're safe
      self.opt_schema.call()
      ### Run as service if requested
      return run_webservice(self.opt_schema, self.start_db) if self.opt_webservice

      json = run_standalone(self.opt_schema, self.start_db, SimpleConsoleLogger.new)
      if self.opt_output_file
        then File.open(self.opt_output_file, 'w') { |f| f.write(json) }
        else puts(json) end
      shutdown_db
    end

    def run_standalone(schema_maker, scout_maker, logger)
      schema   = schema_maker.call()
      scout    = scout_maker.call()
      scout.verifier.init_from_json schema
      counts   = scout.new_counts
      logger   = SimpleConsoleLogger.new unless logger
      progress = lambda do |mode, what, num|
        if ((num % self.opt_report) == 0) || (mode == :finish)
          logger.info("#{DateTime.now}: #{what} ITERATOR PROGRESS (#{mode} / #{num})")
        end
      end
      scout.count_edges counts: counts, report_progress: progress unless self.opt_no_edges
      scout.count_nodes counts: counts, report_progress: progress unless self.opt_no_nodes
      counts.add_to_json schema
      schema.to_json
    end

    def run_webservice(schema_maker, scout_maker)
      ### Run sinatra
      require 'sinatra'

      set :port, @opt_port if @opt_port
      set :bind, @opt_bind if @opt_bind
      set :show_exceptions, true
      set :sessions, false
      set :logging, true
      set :dump_errors, true
      set :lock, true # -- really?
      set :root, File.expand_path("../../root", __FILE__)
      set :run, true
      # set :public_folder

      ### Keep self around for calling helpers in sinatra handlers
      main = self

      ### Return schema
      get '/schema' do
        content_type :json
        schema_maker.call().to_json
      end

      ### Run verify over database and report results
      get '/verify' do
        content_type :json
        main.run_standalone(schema_maker, scout_maker, self.logger)
      end

      ### Shutdown server, the hard way
      get '/shutdown' do
        main.shutdown_db
        java.lang.System.exit(0)
      end
    end
  end

end