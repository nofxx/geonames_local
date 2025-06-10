# require 'iconv'
#---
# Iconv cool tip from http://po-ru.com/diary/fixing-invalid-utf-8-in-ruby-revisited/

module Geonames
  class SHP
    def initialize(file)
      @file = file
      @fname = begin
        file.split('/')[-1]
      rescue StandardError
        nil
      end
      @type = Object.module_eval("::#{Opt[:type].capitalize}", __FILE__, __LINE__)
      # @ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      @sample = nil
      return unless file

      shp2pg
      parse
      write
    end

    def shp2pg
      info 'Converting SRID'
      `shp2pgsql -D -as 4326 #{@file} nil > /tmp/#{@fname}.dump`
    end

    def parse_line(l)
      return if l =~ /^SET\s|^BEGIN;|^COPY\s|^END;|^\\/

      utf = l.encode('UTF-8')
      unless @sample
        info "Free sample\n" + utf.inspect
        @sample = true
      end
      @type.new(Opt[:map], utf, Opt[:nation].upcase, Opt[:city])
    end

    def parse
      info 'Parsing dump'
      start = Time.now
      red = 0
      File.open("/tmp/#{@fname}.dump") do |f|
        while line = f.gets
          next unless record = parse_line(line.chomp)

          @table ||= record.table
          Cache[@table] << record
          red += 1
        end
      end
      info "#{red} parsed. #{Time.now - start}s"
    end

    def reduce!
      hsh = Cache[:roads].group_by(&:name) # Group roads by name

      hsh.map do |_key, roads_in_group|
        next if roads_in_group.empty? # Skip if group is empty

        # Take the first road as the one to update. Its original geometry properties (SRID, Z/M) will be used.
        base_road = roads_in_group.first
        original_geom = base_road.geom

        srid = original_geom&.srid || 4326 # Default SRID if original_geom or its srid is nil
        with_z = original_geom&.with_z || false
        with_m = original_geom&.with_m || false

        all_individual_line_strings = []
        roads_in_group.each do |road|
          geom = road.geom
          if geom.is_a?(GeoRuby::SimpleFeatures::MultiLineString)
            # Add all LineString components from the MultiLineString
            geom.geometries.each do |component|
              all_individual_line_strings << component if component.is_a?(GeoRuby::SimpleFeatures::LineString)
            end
          elsif geom.is_a?(GeoRuby::SimpleFeatures::LineString)
            # Add the LineString itself
            all_individual_line_strings << geom
          elsif geom && Geonames::Opt[:verbose] # Log if it's some other geometry type we're not handling
            Geonames.info "[WARN] Road '#{road.name}' has unhandled geometry type for merging: #{geom.class}"
          end
        end

        # Remove nils, though ideally components shouldn't be nil if checks above are correct
        all_individual_line_strings.compact!

        if all_individual_line_strings.empty?
          # If no valid linestrings, create an empty MultiLineString
          base_road.geom = GeoRuby::SimpleFeatures::MultiLineString.from_line_strings([], srid, with_z, with_m)
        else
          # Create a new MultiLineString from all collected linestrings
          base_road.geom = GeoRuby::SimpleFeatures::MultiLineString.from_line_strings(all_individual_line_strings,
                                                                                      srid, with_z, with_m)
        end

        base_road # Return the modified base_road
      end.compact # Remove nils if any group was empty and returned nil from 'next'
    end

    def write
      db = Postgis.new(Opt[:db])
      Geonames::CLI.do_write(db, Cache[:zones])
      Geonames::CLI.do_write(db, reduce!)
    end

    def self.import(file)
      new(file)
    end
  end
end
