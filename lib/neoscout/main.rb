require 'optparse'
require 'json'
require 'httparty'

module NeoScout

  def self.load_schema(url)
    url.match(/(file:\/\/)(.+)/) do |m|
        return ::JSON.parse(IO::read(file=m[2]))
    end

    ::JSON.parse(HTTParty.get(url))
  end

  def self.main
    options = {}
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

    puts options.to_s

    require 'sinatra'

    set :port, options[:port] if options[:port]
    set :bind, options[:bind] if options[:bind]
    set :show_exceptions, true
    set :sessions, false
    set :logging, true
    set :dump_errors, true
    set :lock, true # -- really?
    set :root, File.expand_path("../../lib", __FILE__)
    set :run, true
#    set :public_folder

    get '/schema' do
      content_type :json
      NeoScout.load_schema(options[:schema]).to_json
    end

  end

end