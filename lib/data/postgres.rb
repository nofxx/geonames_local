require "pg"

module Geonames
  class Postgres
    Countries = {}
    Provinces = {}

    def initialize(opts) #table, addr = "localhost", port = 5432)
      @conn = PGconn.new(opts)
    end

    def write(some)
      country_id = Countries[some.country] ||=
          @conn.exec("SELECT countries.id FROM countries WHERE UPPER(countries.abbr) = UPPER('#{some.country}')")[0]["id"] rescue nil
      unless country_id
        mwrite("countries", { :name => Codes[country.downcase.to_sym][:pt_br],
               :abbr => some.country })
      end
      province_id = Provinces[some.province] ||=
        find("provinces", Cache[:dump].find{ |p| p.province == some.province}.gid)

      if some.kind == :cities
        mwrite("cities", {:name => some.name, :country_id => country_id,
                 :geom => some.geom.as_hex_ewkb, :gid => some.gid,
                 :zip => some.zip, :province_id => province_id})
      else
        mwrite("provinces", { :name => some.name, :abbr => some.abbr,
                 :country_id => country_id, :gid => some.gid })
      end
    end

    def find(kind, id)
      @conn.exec("SELECT #{kind}.id FROM #{kind} WHERE #{kind}.gid = #{id}")[0]["id"] rescue nil
    end

    def escape_name(name)
      name.gsub("'", "''")
    end

    def pg_values(arr)
      arr.map do |v|
        case v
        when String then "E'#{escape_name(v)}'"
        when NilClass then 'NULL'
        else v
        end
      end.join(",")
    end

    def mwrite(table, hsh)
      for_pg = pg_values(hsh.values)
      @conn.exec("INSERT INTO #{table} (#{hsh.keys.join(",")}) VALUES(#{for_pg})")
    end
  end
end
