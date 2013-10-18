#
# Geonames Local
#
require 'optparse'
# Require CLI Stuff
require 'geonames_local/geonames'
require 'geonames_local/data/shp'
require 'geonames_local/data/dump'
require 'geonames_local/data/export'
require 'geonames_local/cli'


module Geonames
  #
  # Command Line Interface for Geonames Local
  #
  #
  class CLI
    def self.parse_options(argv)
      options = {}

      argv.options do |opts|
        opts.banner = 'Geonames Command Line Usage\n\n    geonames <nation code(s)> <opts>\n\n\n'

        opts.on('-l', '--level LEVEL', String, 'The level of logging to report') { |level| options[:level] = level }
        opts.on('-d', '--dump', 'Dump DB before all') { options[:dump] = true }
        opts.separator ''
        opts.separator 'Config file:'
        opts.on('-c', '--config CONFIG', String, 'Geonames Config file path') { |file|  options[:config] = file }
        opts.on('-i', '--import CONFIG', String, 'Geonames Import SHP/DBF/GPX') { |file|  options[:shp] = file }
        opts.separator ''
        opts.separator 'SHP Options:'
        opts.on('--map TYPE', Array, 'Use zone/road to import') { |s| options[:map] = s.map(&:to_sym) }
        opts.on('--type TYPE', String, 'Use zone/road to import') { |s| options[:type] = s }
        opts.on('--city CITY', String, 'Use city gid to import') { |s| options[:city] = s }
        opts.on('--nation NATION', String, 'Use nation gid to import') { |s| options[:nation] = s }
        opts.separator ''
        opts.separator 'Common Options:'
        opts.on('-h', '--help', 'Show this message') { puts opts; exit }
        opts.on('-v', '--verbose', 'Turn on logging to STDOUT') { |bool| options[:verbose] = bool }
        opts.on('-V', '--version', 'Show version') {  puts Geonames::VERSION;  exit }
        opts.separator ''
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

      def load_config
        info "Loading config file..."
        if Opt[:config]
          Opt.merge! YAML.load(File.read(Opt[:config]))
        else
          # Load config/geonames.yml if there's one
          if File.exists?(cfg = File.join('config', 'geonames.yml'))
            Opt.merge! YAML.load(File.read(cfg))
          else
            fail
          end
        end
      rescue
        info "Can't find config file"
        exit
      end

      # Ugly but works?
      def work(argv)
        info "Geopolitical Local Start!"

        trap(:INT) { stop! }
        trap(:TERM) { stop! }
        Opt.merge! parse_options(argv)
        if Opt[:locales].nil? || Opt[:locales].empty?
          Opt[:locales] = ['en']
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
            str = [val.values, key.to_s].join(' ').downcase
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
        if argv[0] =~ /scaff|conf|init/
          fname = (argv[1] || 'geonames') + '.yml'
          if File.exist?(fname)
            puts "File exists: #{fname}"
          else
            puts "Writing to #{fname}"
            `cp #{File.join(File.dirname(__FILE__), 'config', 'geonames.yml')} #{fname}`
          end
          exit
        end

        #
        # Require georuby optionally
        #
        require 'geo_ruby' if Opt[:mapping] && Opt[:mapping][:geom]

        #
        # Load config if we got til here
        #
        load_config

        #
        # Export Data as CSV or JSON
        #
        if argv[0] =~ /csv|json/
          Geonames::Export.new(Nation.all).to_csv

          #
          # Do the magic! Import Geonames Data
          #
        else
          load_adapter(Opt[:store])
          info "Using adapter #{Opt[:store]}.."

          # Nations
          if Opt[:nations].empty? || argv[0] =~ /coun|nati/
            info "\nPopulating 'nations' database..."
            dump = Geonames::Dump.new(:all, :dump)
            info "\n---\nTotal #{dump.data.length} parsed."

            info 'Writing to nations DB'
            Geonames::Models::MongoWrapper.nations dump.data, Opt[:clean]

            # Regions, Cities....
          else
            zip = Geonames::Dump.new(Opt[:nations], :zip).data
            dump = Geonames::Dump.new(Opt[:nations], :dump).data
            info "\n---\nTotal #{dump.size} parsed. #{zip.size} zips."

            info 'Join dump << zip'
            dump = unify!(dump, zip).group_by(&:kind)

            info 'Writing to DB...'
            Geonames::Models::MongoWrapper.batch dump, Opt[:clean]
            # info "Writing cities..."
            # Geonames::Models::City.from_batch dump[:city]
          end
        end
      end

      def load_adapter(name)
        begin
          require "geonames_local/models/#{name}"
        rescue LoadError
          info "Can't find adapter for #{name}"
          stop!
        end
      end

      def unify!(dump, zip)
        start = Time.now
        dump.map! do |spot|
          if other = zip.find { |d| d.code == spot.code }
            spot.zip = other.zip
            spot
          else
            spot
          end
        end
        info "Done. #{(Time.now - start).to_i}s"
        dump
      end

      def stop!
        puts 'Closing Geonames...'
        exit
      end

    end # class < self

  end # CLI

end # Geonames
