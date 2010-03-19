
module Geonames
  class Mongo

    def initialize(conn=nil, resource=nil, extra=nil)
      if conn
        require 'tokyotyrant'
        resource ||= 'localhost'
        extra ||= 1978
        @tbl = TokyoTyrant::RDBTBL
        @qry = TokyoTyrant::RDBQRY
      else
        require 'tokyocabinet'
        resource ||= 'geonames.tct'
        extra ||= (TokyoCabinet::TDB::OWRITER | TokyoCabinet::TDB::OCREAT)
        @tbl = TokyoCabinet::TDB
        @qry = TokyoCabinet::TDBQRY
      end
      @rdb = @tbl.new
      @rdb.open(resource, extra)
      set_indexes
    end
end
  end
