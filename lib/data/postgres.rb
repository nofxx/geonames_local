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

      p = Provinces[some.province] ||= find("provinces", Cache[:provinces].
                                       find{ |p| p.province == some.province}.gid)
      [c, p]
    end

    #
    # Insert a record
    def insert(some)
      country_id, province_id = get_some_ids(some)
      if some.kind == :cities
        write("cities", {:name => some.name, :country_id => country_id,
                 :geom => some.geom.as_hex_ewkb, :gid => some.gid,
                 :zip => some.zip, :province_id => province_id})
      else
        write("provinces", { :name => some.name, :abbr => some.abbr,
                 :country_id => country_id, :gid => some.gid })
      end
    end

    #
    # Find a record`s ID
    def find(kind, id)
      @conn.exec("SELECT #{kind}.id FROM #{kind} WHERE #{kind}.gid = #{id}")[0]["id"] rescue nil
    end

    #
    # F'oo -> F''oo  (for pg)
    def escape_name(name)
      name.gsub("'", "''")
    end

    #
    # Sanitize values por pg.. here until my lazyness open pg rdoc...
    def pg_values(arr)
      arr.map do |v|
        case v
        when String then "E'#{escape_name(v)}'"
        when NilClass then 'NULL'
        else v
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
