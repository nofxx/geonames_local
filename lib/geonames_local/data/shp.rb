# require 'iconv'
#---
# Iconv cool tip from http://po-ru.com/diary/fixing-invalid-utf-8-in-ruby-revisited/

module Geonames
  class SHP

    def initialize(file)
      @file = file
      @fname = file.split("/")[-1] rescue nil
      @type = Object.module_eval("::#{Opt[:type].capitalize}", __FILE__, __LINE__)
      # @ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      @sample = nil
      if file
        shp2pg; parse; write
      end
    end

    def shp2pg
      info "Converting SRID"
      `shp2pgsql -D -as 4326 #{@file} nil > /tmp/#{@fname}.dump`
    end

    def parse_line(l)
      return if l =~ /^SET\s|^BEGIN;|^COPY\s|^END;|^\\/
      utf = l.encode('UTF-8')
      unless @sample
        info "Free sample\n" + utf.inspect
        @sample = true
      end
      @type.new(Opt[:map], utf, Opt[:country].upcase, Opt[:city])
    end

    def parse
      info "Parsing dump"
      start = Time.now
      red = 0
      File.open("/tmp/#{@fname}.dump") do |f|
        while line = f.gets
          if record = parse_line(line.chomp)
            @table ||= record.table
            Cache[@table] << record
            red += 1
          end
        end
      end
      info "#{red} parsed. #{Time.now-start}s"
    end

    def reduce!
      hsh = Cache[:roads].group_by { |r| r.name }
      arr = []
      hsh.map do |key, vals|
        first = vals.delete_at(0)
#        p vals[0].geom.geometries.concat(vals[1].geom.geometries)
        vals.map(&:geom).each do |g|
          first.geom.geometries.concat g.geometries
        end
        # = GeoRuby::SimpleFeatures::MultiLineString.
        #  from_line_strings([*vals.map(&:geom).map(&:geometries)])
        first
      end
    end

    def write
      db = Postgres.new(Opt[:db])
      Geonames::CLI.do_write(db, Cache[:zones])
      Geonames::CLI.do_write(db, reduce!)
    end

    def self.import(file)
      new(file)
    end
  end
end
