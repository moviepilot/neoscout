require 'optparse'
require 'json'
require 'httparty'

module NeoScout

  def self.load_schema(url, file_ok=false)
    url.match(/(file:\/\/)(.+)/) do |m|
      return ::JSON.parse(IO::read(file=m[2])) if file_ok
      raise ArgumentError("No file url allowed")
    end

    ::JSON.parse(HTTParty.get(url))
  end

  def self.init_db(db)
    db.match(/(neo4j:)(.*)/) do |m|
      Neo4j.config[:storage_path] = m[2] unless (m[2].length == 0)
      return lambda { ::NeoScout::GDB_Neo4j::Scout.new }
    end

    raise ArgumentError("Unsupported database type")
  end

  # TODO turn into class
  def self.main

    ### Parsing options

    options  = {}
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: --db <neo4j:path> --schema <url> [--port <port>]"
      opts.on('-d', '--db DB', 'Path to database in the form neo4j:<path>)') do |db|
        options[:db] = db
      end
      opts.on('-s', '--schema-url SCHEMA', 'URL to database schema') do |schema|
        options[:schema] = schema
      end
      opts.on('-p', '--port PORT', 'Port to be used') do |port|
        options[:port] = port.to_i
      end
      opts.on('-b', '--bind ITF', 'Interface to be used') do |itf|
        options[:bind] = itf
      end
      opts.on('-h', '--help', 'Display this screen') do
        puts opts
        exit 1
      end
    end
    optparse.parse!

    puts "neoscout loaded with options: #{options.to_s}"

    ### Load schema at least once to know that we're safe
    load_schema(options[:schema], true)

    ### Load database
    scout_maker = init_db(options[:db])

    ### Run sinatra
    require 'sinatra'

    set :port, options[:port] if options[:port]
    set :bind, options[:bind] if options[:bind]
    set :show_exceptions, true
    set :sessions, false
    set :logging, true
    set :dump_errors, true
    set :lock, true # -- really?
    set :root, File.expand_path("../../root", __FILE__)
    set :run, true
#    set :public_folder

    get '/schema' do
      content_type :json
      NeoScout.load_schema(options[:schema], true).to_json
    end

    get '/verify' do
      content_type :json

      schema = NeoScout.load_schema(options[:schema])
      scout  = scout_maker.call()
      scout.verifier.init_from_json schema
      counts = scout.new_counts
      scout.count_edges counts: counts
      scout.count_nodes counts: counts
      counts.add_to_json schema
      schema.to_json
    end

  end

end