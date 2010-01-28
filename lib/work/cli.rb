#
# Geonames Local
#
module Geonames
  class CLI

    def self.parse_options(argv)
      options = {}

      ARGV.options do |opts|
        opts.banner = <<BANNER
Geonames Command Line Usage:

geonames <country code(s)> <opts>

BANNER
        opts.on("-l", "--level LEVEL", String, "The level of logging to report" ) { |level| options[:level] = level }
        opts.on("-d", "--dump", "Dump DB before all" ) { options[:dump] = true }
        opts.separator ""
        opts.separator "Config file:"
        opts.on("-c", "--config CONFIG", String, "Geonames Config file path" ) { |file|  options[:config] = file }
        opts.separator ""
        opts.separator "Tyrant Options:"
        opts.on("-t", "--tyrant", "Use tyrant" ) { options[:tyrant] = true }
        opts.on("-s", "--server SERVER", String, "Tyrant Server URL" ) { |url|  options[:server] = url }
        opts.on("-p", "--port PORT", Integer, "Tyrant Server Port")  { |val| options[:port] = val.to_i }
        opts.separator ""
        opts.separator "Common Options:"
        opts.on("-h", "--help", "Show this message" ) { puts opts; exit }
        opts.on("-v", "--verbose", "Turn on logging to STDOUT" ) { |bool| options[:verbose] = bool }
        opts.on("-V", "--version", "Show version") {  puts Geonames::VERSION;  exit }
        opts.separator ""
        begin
          opts.parse!
          if argv.empty? && !options[:config]
            puts opts
            exit
          end
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

      if Opt[:config]
        Opt.merge! YAML.load(File.read(Opt[:config]))
      end

      if argv[0] =~ /list|codes/
         Codes.each do |key,val|
          str = [val.values, key.to_s].join(" ").downcase
          if s = argv[1]
            next unless str =~ /#{s.downcase}/
          end
          puts "#{val[:en_us]}: #{key}"
        end
        exit
      end

      if argv[0] =~ /scaff|conf/
        puts "Writing to geonames.yml"
        File.open("geonames.yml", "w+") do |f|
          f << Opt.to_yaml
        end
        exit
      end
      require "geo_ruby" if Opt[:mapping] && Opt[:mapping][:geom]

      if argv[0] =~ /csv|json/
        Geonames::Export.new(Country.all).to_csv
      else
        puts "Dumping zip for #{Opt[:codes]}"
        Geonames::Dump.work(Opt[:codes], :zip) #rescue puts "Command not found: #{comm} #{@usage}"
        puts "Dumping all for #{Opt[:codes]}"
        Geonames::Dump.work(Opt[:codes], :dump) #rescue puts "Command not found: #{comm} #{@usage}"
        puts "Total #{Cache[:zip].length}"
        puts "Join dump << zip"
        unify!
        write_to_store!
      end
    end

    def self.write_to_store!
      db = case Opt[:store].to_sym
           when :tyrant then Geonames::Tokyo.new(Opt[:tyrant])
           when :pg     then Geonames::Postgres.new(Opt[:db])
           else
             info "No store defined!"
             exit
           end

      groups = Cache[:dump].group_by(&:kind)
      Cache[:provinces] = groups[:provinces]
      # ensure this order....
      do_write(db, groups[:provinces])
      do_write(db, groups[:cities])
    end

    def self.do_write(db, val)
      key = val[0].kind
      start = Time.now
      writt = 0
      info "Writing #{key}..."
      val.each do |v|
        unless db.find v.kind, v.gid
          db.insert v
          writt += 1
        end
      end
      total = Time.now - start
      info "#{writt} #{key} written in #{total} sec (#{(writt/total).to_i}/s)"
    end

    def self.unify!
      Cache[:dump].map! do |spot|
        if other = Cache[:zip].find { |d| d.code == spot.code }
          spot.zip = other.zip
          spot
        else
          spot
        end
      end

    end

    def self.stop!
      puts "Closing Geonames..."
    end

  end

end
