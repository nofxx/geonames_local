module Geonames
  class Cli

    def self.parse_options(argv)
      options = {}

      ARGV.options do |opts|
        opts.banner = <<BANNER
Geonames Gem Usage:

geonames [command] [opts]

Commands:

   dump
   sync

BANNER
        opts.separator "Config file:"
        opts.on("-c", "--config CONFIG", String, "Geonames Config file path" ) { |file|  options[:config] = file }
        opts.separator ""
        opts.separator "Operation mode:"
        opts.on("-m", "--mode MODE", String, "Geonames operation mode")   { |val| options[:mode] = val.to_sym }
        opts.separator ""
        opts.separator "   xmpp   -  Use xmpp client, requires JID and Password"
        opts.separator "   post   -  Use post client, requires Geonames Web Key"
        opts.separator ""
        opts.separator "Server Options:"
        opts.on("-s", "--server SERVER", String, "Geonames Server URL" ) { |url|  options[:server] = url }
        opts.on("-p", "--port PORT", Integer, "Geonames Server Port")  { |val| options[:port] = val.to_i }
        opts.separator ""

        opts.on("-l", "--level LEVEL", Logger::SEV_LABEL.map { |l| l.downcase }, "The level of logging to report" ) { |level| options[:level] = level }

        opts.separator ""
        opts.separator "Common Options:"
        opts.on("-h", "--help", "Show this message" ) { puts opts; exit }
        opts.on("-v", "--[no-]verbose", "Turn on logging to STDOUT" ) { |bool| options[:verbose] = bool }
        opts.on("-V", "--version", "Show version") { |version|  puts Geonames::VERSION;  exit }
        opts.separator ""
        begin
          opts.parse!
          @usage = opts.to_s
        rescue
          puts opts
          exit
        end
      end
      options
    end
    private_class_method :parse_options

    def self.work(argv)
      trap(:INT) { stop! }
      trap(:TERM) { stop! }

#      Opt.autoload_config(
                          parse_options(argv)

      comm = argv.shift || "dump"
      codes = argv
      Geonames::Worker.send(comm, codes) #rescue puts "Command not found: #{comm} #{@usage}"
    end

    def self.stop!
      puts "Closing Geonames..."
    end

  end

end
