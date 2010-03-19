require "mongo"

module Geonames
  class Mongodb

    RESOURCES = ["countries", "provinces", "cities"]

    def initialize(params)
      host, port = params[:host] || "localhost", params[:port] || 27017
      @conn = Mongo::Connection.new(host, port)
      @db = @conn.db(params[:dbname])
      #purge
      setup
    end

    def setup
      for re in RESOURCES
        coll = @db.collection(re)
        coll.create_index(["id", Mongo::ASCENDING], ["gid", Mongo::ASCENDING])
        coll.create_index([["geom", Mongo::GEO2D]], :min => 0, :max => 180)
      end
    end

    def all(resource)
      @db.collection(resource.to_s).find().to_a
    end

    def find(resource, id, name=nil)
      @db.collection(resource.to_s).find_one("id" => id)
    end

    def find_near(resource, x, y)
      @db.collection(resource.to_s).find("geom" => { "$near" => { "x" => x, "y" => y }}).to_a
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

    def near(resource, x,y)
      cmd = OrderedHash.new
      cmd["geoNear"] = resource
      cmd["near"] = sin_proj(x,y)
      @db.command(cmd) #{"command" => OrderedHash.new({ "geoNear" => resource, "near" => sin_proj(x,y) })})
    end

    private

    def sin_proj(x,y)
      x_sin = x * Math.cos(y * Math::PI/180)
      { :x => x_sin, :y => y}
      #[x_sin, y]
    end
  end
end
