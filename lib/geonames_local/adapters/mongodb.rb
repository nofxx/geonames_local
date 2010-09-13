require "mongo"

module Geonames
  class Mongodb

    RESOURCES = ["countries", "provinces", "cities"]

    def initialize(params={})
      host, port = params[:host] || "localhost", params[:port] || 27017
      @conn = Mongo::Connection.new(host, port)
      @db = @conn.db(params[:dbname] || "geonames")
      if params[:user] || params[:password]
        @db.authenticate(params[:user], params[:password])
      end
      #purge
      setup
    end

    def setup
      for re in RESOURCES
        coll = @db.collection(re)
        coll.create_index([["id", Mongo::ASCENDING], ["gid", Mongo::ASCENDING]])

        # Geometric index, more info:
        # http://www.mongodb.org/display/DOCS/Geospatial+Indexing
        coll.create_index([["geom", Mongo::GEO2D]], :min => -180, :max => 180)
      end
    end

    def all(resource, limit=nil, skip=0)
      @db.collection(resource.to_s).find().to_a
    end

    def first(resource)
      @db.collection(resource.to_s).find_one
    end

    def find(resource, id, name=nil)
      @db.collection(resource.to_s).find_one("id" => id)
    end

    def find_by_name(resource, name)
      do_find(resource, "name" => /#{name}/i)
    end

    def find_by_zip(resource, zip)
      do_find(resource, "zip" => /#{zip}/)
    end

    def do_find(resource, hsh)
      @db.collection(resource.to_s).find(hsh).to_a
    end

    def insert(resource, spot)
      hsh = spot.to_hash
      hsh["geom"][0] = sin_proj(hsh["geom"])[0] if hsh["geom"]
      @db.collection(resource.to_s).insert(hsh)
    end

    def count(resource)
      @db.collection(resource).count
    end

    def find_near(resource, x, y, limit=nil, skip=0)
      coll = @db.collection(resource.to_s).find("geom" => { "$near" => { "x" => x, "y" => y }}).skip(skip)
      coll.limit(limit) if limit
      coll.to_a
    end

    # +1.3.4
    def find_within(resource, geom, limit=nil)
      op = geom[1].kind_of?(Numeric) ? "$center" : "$box"
      coll = @db.collection(resource.to_s).find("geom" => { "$within" => { op => geom }})
      coll.limit(limit) if limit
      coll.to_a
    end

    # getNear command returns distance too
    # <1.9 needs OrderedHash
    def near(resource, x, y, limit=nil)
      cmd = OrderedHash.new
      cmd["geoNear"] = resource
      cmd["near"] = sin_proj(x,y)
      cmd["num"] = limit if limit
      @db.command(cmd)["results"].to_a
    end

    def purge
      for re in RESOURCES
        @db.drop_collection(re)
      end
    end

    def index_info(resource)
      @db.collection(resource).index_information
    end

    private

    def sin_proj(x,y=nil)
      x,y = x unless y
      [x * Math.cos(y * Math::PI/180), y]
    end
  end
end
