#
# Geonames Local
#
require 'zip'
require 'optparse'
require 'benchmark'
# Require CLI Stuff
require 'geonames_local/data/shp'
require 'geonames_local/data/dump'
require 'geonames_local/data/export'

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
        opts.on('-d', '--dump', 'Dump DB before all') { options[:clean] = true }
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
        info 'Loading config file...'
        if Opt[:config] && File.exist?(Opt[:config])
          Opt.merge! YAML.load(File.read(Opt[:config]))
        elsif File.exist?(cfg = File.join('config', 'geonames.yml'))
          # Load config/geonames.yml if there's one
          Opt.merge! YAML.load(File.read(cfg))
        else
          STDERR.puts "No config file...'#{Opt[:config] || 'geonames.yml'}'"
          exit 1
        end
      end

      def trap_signals
        puts '󰣩 Geopolitical Local Start!'
        trap(:INT) { stop! }
        trap(:TERM) { stop! }
      end

      def wrapper
        Geonames::Models::MongoWrapper
      end

      def work_nations
        info "\n[NATIONS] Populating main 'nations' database..."
        dump = Geonames::Dump.new(:all, :dump)
        info "\n---\nTotal #{dump.data.length} parsed."

        info '[NATIONS] Writing to nations DB'
        wrapper.nations dump.data
      end

      def work_spots
        info "\n[SPOTS] Populating 'regions' and 'cities' database..."
        zip = Geonames::Dump.new(Opt[:nations], :zip).data
        dump = Geonames::Dump.new(Opt[:nations], :dump).data
        info "\n---\nTotal #{dump.size} parsed. #{zip.size} postal codes."

        info '[SPOTS] Join dump << zip'
        dump = unify!(dump, zip).group_by(&:kind)

        info '[SPOTS] Writing to DB...'
        wrapper.batch dump
      end

      # Ugly but works?
      def work(argv)
        trap_signals
        Opt.merge! parse_options(argv)

        Opt[:locales] = ['en'] if Opt[:locales].nil? || Opt[:locales].empty?

        if (shp = Opt[:shp])
          SHP.import(shp)
          exit
        end

        # Step 6: Handle list/codes command
        if argv[0] =~ /list|codes/
          Codes.each do |key, val|
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

        # Load config if we got til here
        load_config
        puts Opt[:store]
        puts Opt

        # Export Data as CSV or JSON
        return Geonames::Export.new(Nation.all).to_csv if argv[0] =~ /csv|json/

        # Do the magic! Import Geonames Data
        load_adapter(Opt[:store])
        info "Using adapter #{Opt[:store]}.."
        wrapper.clean if Opt[:clean]
        puts Benchmark.measure { work_nations }# unless wrapper.nations_populated?
        puts Benchmark.measure { work_spots }
      end

      def load_adapter(name)
        require_relative "models/#{name}"
      rescue LoadError => e
        info "Can't find adapter for #{name} #{e}"
        stop!
      end

      def unify!(dump, zip)
        start = Time.now
        dump.map! do |spot|
          next spot unless (other = zip.find { |z| z.code == spot.code })
          spot.zip = other.zip
          spot
        end
        info "Done. #{(Time.now - start).to_i}s"
        dump
      end

      def stop!
        info 'Closing Geonames...'
        exit
      end
    end # class < self
  end # CLI
end # Geonames
