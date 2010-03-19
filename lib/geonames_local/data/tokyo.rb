
module Geonames
  class Tokyo

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

    def all(params)
      qry = @qry.new(@rdb)
      params.each do |k,v|
        #qry.addcond(k.to_s, Q::QCNUMEQ, v.to_s)
        qry.addcond(k.to_s, @qry::QCSTREQ, v.to_s)
      end
      qry.setorder("name", @qry::QOSTRASC)
      qry.search.map { |id| @rdb.get(id) }
    end

    def find(id)
      #qry = Q.new(@rdb)
      #qry.addcond("gid", Q::QCNUMEQ, id.to_s)
      #qry.setlimit(10)
      #id = qry.search.pop
      @rdb.get(id)
    end

    # def to_obj(hsh)
    #   hsh["kind"] == "country" ? Country.new(hsh) : Spot.new(hsh)
    # end

    def write(o)
      # pkey = @rdb.genuid
      if @rdb.put(o.gid, o.to_hash)
       # info "ok"
      else
        info "err #{@rdb.errmsg(@rdb.ecode)}"
      end
    end

    def count
      @qry.new(@rdb).search.length
    end

    def close
      # close the database
      if !@rdb.close
        STDERR.printf("close error: %s\n", @rdb.errmsg(@rdb.ecode))
      end
    end

    def set_indexes
      #for index in indexes
      # @rdb.setindex("gid", @tbl::ITOPT)
      @rdb.setindex("kind", @tbl::ITLEXICAL)
      @rdb.setindex("name", @tbl::ITQGRAM)
      @rdb.setindex("country", @tbl::ITLEXICAL)

      #end

    end

    def flush
      @rdb.vanish
    end


  end

end
