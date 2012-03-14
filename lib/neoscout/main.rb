require 'optparse'

module NeoScout

  def self.main
    options = {}
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: --db <neo4j:path> --schema <url> [--port <port>]"
      opts.on('-d', '--db', 'Path to database in the form neo4j:<path>)') do |o|
        options[:db] = o
      end
      opts.on('-s', '--schema-url', 'URL to database schema') do |o|
        options[:schema] = o
      end
      opts.on('-p', '--port', 'Port to be used') do |o|
        options[:o] = o.to_i
      end
      opts.on('-h', '--help', 'Display this screen') do
        puts opts
        exit 1
      end
    end
    optparse.parse!
  end

end