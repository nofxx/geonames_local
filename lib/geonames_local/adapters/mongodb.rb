require "mongo"

module Geonames
  class Mongodb

    RESOURCES = ["countries", "provinces", "cities"]

    def initialize(params)
      host, port = params[:host] || "localhost", params[:port] || 27017
      @conn = Mongo::Connection.new(host, port)
      @db = @conn.db(params[:dbname])
      # purge
      setup
    end

    def setup
      for re in RESOURCES
        coll = @db.collection(re)
        coll.create_index(["id", Mongo::ASCENDING])
        coll.create_index(["gid", Mongo::ASCENDING])
        coll.create_index(["geom", Mongo::GEO2D], :min => 0, :max => 180)
      end
    end

    def find(resource, id, name=nil)
      @db.collection(resource.to_s).find_one("id" => id)
    end

    def insert(resource, spot)
      @db.collection(resource.to_s).insert(spot.to_hash)
    end

    def count(resource)
      @db.collection(resource).count
    end

    def purge
      for re in RESOURCES
        @db.drop_collection(re)
      end
    end

    def index_info(resource)
      @db.collection(resource).index_information
    end

  end
end
