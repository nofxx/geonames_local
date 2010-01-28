require "pg"

module Geonames
  class Postgres
    Countries = {}
    Provinces = {}

    def initialize(opts) #table, addr = "localhost", port = 5432)
      @conn = PGconn.new(opts)
    end

    #
    # Get Country and Province ID from the DB
    def get_some_ids(some)
      c = Countries[some.country] ||=
          @conn.exec("SELECT countries.id FROM countries WHERE UPPER(countries.abbr) = UPPER('#{some.country}')")[0]["id"] rescue nil
      c ||= write("countries", {:name => Codes[some.country.downcase.to_sym][:pt_br], :abbr => some.country })

      p = nil
      ci = nil
      if some.kind_of? Spot
        p = Provinces[some.province] ||= find("provinces", Cache[:provinces].
                                       find{ |p| p.province == some.province}.gid)
      else
        ci = find("cities", some.city)
        p = @conn.exec("SELECT cities.province_id FROM cities WHERE cities.id = #{ci}")[0]["province_id"] rescue nil
      end
      [c, p, ci]
    end

    #
    # Insert a record
    def insert(some)
      country_id, province_id, city_id = get_some_ids(some)
      case some.table
      when :cities
        write("cities", {:name => some.name, :country_id => country_id,
                 :geom => some.geom.as_hex_ewkb, :gid => some.gid,
                 :zip => some.zip, :province_id => province_id})
      when :provinces
        write("provinces", { :name => some.name, :abbr => some.abbr,
                 :country_id => country_id, :gid => some.gid })
      when :roads
        write("roads", { :name => some.name, :geom => some.geom.as_hex_ewkb, :kind => some.kind,
                 :country_id => country_id, :city_id => city_id, :province_id => province_id })
      end
    end

    #
    # Find a record`s ID
    def find(table, id, name=nil)
      begin
        if name
          @conn.exec("SELECT #{table}.id FROM #{table} WHERE (#{table}.name = E'#{id}')")[0]["id"]
        else
          @conn.exec("SELECT #{table}.id FROM #{table} WHERE #{table}.gid = #{id}")[0]["id"]
        end
      rescue => e
        nil
      end
    end

    #
    # F'oo -> F''oo  (for pg)
    def escape_name(name)
      name.to_s.gsub("'", "''")
    end

    #
    # Sanitize values por pg.. here until my lazyness open pg rdoc...
    def pg_values(arr)
      arr.map do |v|
        case v
        when Symbol, String then "E'#{escape_name(v)}'"
        when NilClass then 'NULL'
        else
        end
      end.join(",")
    end

    #
    # Naive PG insert ORM =D
    def write(table, hsh)
      for_pg = pg_values(hsh.values)
      @conn.exec("INSERT INTO #{table} (#{hsh.keys.join(",")}) VALUES(#{for_pg}) RETURNING id")[0]["id"]
    end

    def exec(comm)
      @conn.exec(comm)
    end
  end
end
