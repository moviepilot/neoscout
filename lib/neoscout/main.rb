require 'optparse'
require 'json'
require 'httparty'
require 'date'

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

    def initialize
      @opt_report     = 0
      @opt_webservice = true
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
        opts.on('-p', '--port PORT', 'Port to be used') do |port|
          @opt_port   = port.to_i
        end
        opts.on('-b', '--bind ITF', 'Interface to be used') do |itf|
          @port       = itf
        end
        opts.on('-r', '--report NUM', 'Report progress every NUM graph elements') do |num|
          @opt_report = num.to_i
        end
        opts.on('--no-nodes', 'Dont iterate over nodes') do
          @opt_no_nodes = true
        end
        opts.on('--no-edges', 'Dont iterate over edges') do
          @opt_no_edges = true
        end
        opt.on('--w', '--webservice', 'Run inside sinatra') do
          @opt_webservice = true
        end
        opts.on('-h', '--help', 'Display this screen') do
          puts opts
          exit 1
        end
      end
      optparse.parse!
    end

    def start_db
      @opt_db.match(/(neo4j:)(.*)/) do |m|
        Neo4j.config[:storage_path] = m[2] unless (m[2].length == 0)
        Neo4j.start
        return lambda { ::NeoScout::GDB_Neo4j::Scout.new }
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

    def run
      if self.opt_webservice
        then run_webservice
        else run_standalone(nil) end
    end

    class FakeLogger
      def info(*args)
        puts *args
      end
    end

    def run_standalone(logger)
      schema    = main.opt_schema.call()
      scout    = scout_maker.call()
      scout.verifier.init_from_json schema
      counts   = scout.new_counts
      logger   = FakeLogger.new unless logger
      progress = lambda do |mode, what, num|
        if ((num % main.opt_report) == 0) || (mode == :finish)
          logger.info("#{DateTime.now}: #{what} ITERATOR PROGRESS (#{mode} / #{num})")
        end
      end
      scout.count_edges counts: counts, report_progress: progress unless main.opt_no_edges
      scout.count_nodes counts: counts, report_progress: progress unless main.opt_no_nodes
      counts.add_to_json schema
      schema.to_json
    end

    def run_webservice
      ### Load schema at least once to know that we're safe
      @opt_schema.call()

      ### Load database
      scout_maker = self.start_db

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
        main.opt_schema.call().to_json
      end

      ### Run verify over database and report results
      get '/verify' do
        content_type :json

        main.run_standalone(self.logger)
      end

      ### Shutdown server, the hard way
      get '/shutdown' do
        main.shutdown_db
        java.lang.System.exit(0)
      end
    end
  end

end