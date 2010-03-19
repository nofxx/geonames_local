require "mongo"

module Geonames
  class Mongodb

    RESOURCES = ["countries", "provinces", "cities"]

    def initialize(params)
      port = params[:port] || 27017
      @conn = Mongo::Connection.new(params[:host], port)
      @db = @conn.db(params[:dbname])
    end

    def find(resource, id, name=nil)
      @db.collection(resource.to_s).find("id" => id).to_a.first
    end

    def insert(resource, spot)
      @db.collection(resource.to_s).insert(spot.to_hash)
    end

    def purge
      for re in RESOURCES
        @db.drop_collection(re)
      end
    end

  end
end
