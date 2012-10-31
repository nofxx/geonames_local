#
# Geonames Local
#
require 'optparse'
# Require CLI Stuff
require 'geonames_local/geonames'
require 'geonames_local/data/shp'
require 'geonames_local/data/dump'
require 'geonames_local/data/sync'
require 'geonames_local/data/export'
require 'geonames_local/cli'


module Geonames
  class CLI
    def self.parse_options(argv)
      options = {}

      argv.options do |opts|
        opts.banner = <<BANNER
Geonames Command Line Usage:

geonames <country code(s)> <opts>

geonames
BANNER
        opts.on("-l", "--level LEVEL", String, "The level of logging to report" ) { |level| options[:level] = level }
        opts.on("-d", "--dump", "Dump DB before all" ) { options[:dump] = true }
        opts.separator ""
        opts.separator "Config file:"
        opts.on("-c", "--config CONFIG", String, "Geonames Config file path" ) { |file|  options[:config] = file }
        opts.on("-i", "--import CONFIG", String, "Geonames Import SHP/DBF/GPX" ) { |file|  options[:shp] = file }
        opts.separator ""
        opts.separator "SHP Options:"
        opts.on("--map TYPE", Array, "Use zone/road to import" ) { |s| options[:map] = s.map(&:to_sym) }
        opts.on("--type TYPE", String, "Use zone/road to import" ) { |s| options[:type] = s }
        opts.on("--city CITY", String, "Use city gid to import" ) { |s| options[:city] = s }
        opts.on("--country COUNTRY", String, "Use country gid to import" ) { |s| options[:country] = s }
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

    class << self

    # Ugly but works?
    def work(argv)
      trap(:INT) { stop! }
      trap(:TERM) { stop! }
      Opt.merge! parse_options(argv)

      if Opt[:config]
        Opt.merge! YAML.load(File.read(Opt[:config]))
      end

      # Load config/geonames.yml if there's one
      if File.exists?(cfg = File.join("config", "geonames.yml"))
        Opt.merge! YAML.load(File.read(cfg))
      end

      if shp = Opt[:shp]
        SHP.import(shp)
        exit
      end

      #
      # Return Codes and Exit
      #
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

      #
      # If arguments scaffold, config, write down yml.
      #
      if argv[0] =~ /scaff|conf/
        fname = (argv[1] || "geonames") + ".yml"
        if File.exist?(fname)
          puts "File exists."
        else
          puts "Writing to #{fname}"
          `cp #{File.join(File.dirname(__FILE__), 'config', 'geonames.yml')} #{fname}`
        end
        exit
      end

      #
      # Require georuby optionally
      #
      require "geo_ruby" if Opt[:mapping] && Opt[:mapping][:geom]

      #
      # Export Data as CSV or JSON
      #
      if argv[0] =~ /csv|json/
        Geonames::Export.new(Country.all).to_csv

      #
      # Do the magic! Import Geonames Data
      #
      else
        load_adapter(Opt[:store])
        info "Using adapter #{Opt[:store]}.."

        if argv[0] =~ /coun|nati/
          Geonames::Dump.work(Opt[:codes], :dump)
          data = :countries
        else
          Geonames::Dump.work(Opt[:codes], :zip)
          Geonames::Dump.work(Opt[:codes], :dump)
          data = :cities
        end

        info "\n---\nTotal #{Cache[:dump].length} parsed. #{Cache[:zip].length} zips."
        # Sync.work!
        info "Join dump << zip"
        unify!
        info "Writing to DB"
        write_to_store! data
      end
    end

    def load_adapter(name)
      begin
        require "geonames_local/adapters/#{name}"
        require "geonames_local/models/#{name}"
      rescue LoadError
        puts "Can't find adapter #{name}"
        stop!
      end
    end

    def write_to_store! data
      if data == :countries
        Cache[:countries] = Cache[:dump]
        Country.from_batch(Cache[:dump])
      else
        groups = Cache[:dump].group_by(&:kind)

        Province.from_batch groups[:provinces]
        City.from_batch groups[:city]
      end
    end

    def do_write(db, values)
      return if values.empty?

      if Opt[:codes][0] == "country"
        key = table = "countries"
      else
        key = values[0].table
      end
      start = Time.now
      writt = 0
      info "\nWriting #{values.length} #{key}..."
      values.each do |val|
        meth = val.respond_to?(:gid) ? [val.gid] : [val.name, true]
        unless db.find(table || val.table, *meth)
          db.insert(table || val.table, val)
          writt += 1
        end
      end
      total = Time.now - start
      info "#{writt} #{key} written in #{total} sec (#{(writt/total).to_i}/s)"
    end

    def unify!
      start = Time.now
      Cache[:dump].map! do |spot|
        if other = Cache[:zip].find { |d| d.code == spot.code }
          spot.zip = other.zip
          spot
        else
          spot
        end
      end
      info "Done. #{(Time.now-start).to_i}s"
    end

    def stop!
      puts "Closing Geonames..."
      exit
    end
    end

  end

end
