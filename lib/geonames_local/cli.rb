module Geonames
  class Cli

    def self.parse_options(argv)
      options = {}

      ARGV.options do |opts|
        opts.banner = <<BANNER
Geonames Command Line Usage:

geonames <code(s)> <opts>


BANNER
        opts.on("-l", "--level LEVEL", String, "The level of logging to report" ) { |level| options[:level] = level }
        opts.on("-d", "--dump", "Dump DB before all" ) { options[:dump] = true }
        opts.separator ""
        opts.separator "Config file:"
        opts.on("-c", "--config CONFIG", String, "Geonames Config file path" ) { |file|  options[:config] = file }
        opts.separator ""
        opts.separator "Common Options:"
        opts.on("-h", "--help", "Show this message" ) { puts opts; exit }
        opts.on("-v", "--verbose", "Turn on logging to STDOUT" ) { |bool| options[:verbose] = bool }
        opts.on("-V", "--version", "Show version") {  puts Geonames::VERSION;  exit }
        opts.separator ""
        begin
          opts.parse!
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
      Opt.merge! parse_options(argv)

      if argv[0] =~ /csv|json/
        Geonames::Export.new(Country.all).to_csv
      else
        Geonames::Worker.dump(argv) #rescue puts "Command not found: #{comm} #{@usage}"
      end
    end

    def self.stop!
      puts "Closing Geonames..."
    end

  end

end
