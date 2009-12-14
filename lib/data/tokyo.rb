require 'tokyotyrant'

module Geonames
  class Tokyo
    include TokyoTyrant

    def initialize(addr = 'localhost', port=1978)
      @rdb = RDBTBL.new
      @rdb.open(addr, port)
      set_indexes
    end

    def all(params)
      qry = RDBQRY.new(@rdb)
      params.each do |k,v|
        #qry.addcond(k.to_s, RDBQRY::QCNUMEQ, v.to_s)
        qry.addcond(k.to_s, RDBQRY::QCSTREQ, v.to_s)
      end
      qry.setorder("name", RDBQRY::QOSTRASC)
      qry.search.map { |id| to_obj(@rdb.get(id)) }
    end

    def find(id)
      #qry = RDBQRY.new(@rdb)
      #qry.addcond("gid", RDBQRY::QCNUMEQ, id.to_s)
      #qry.setlimit(10)
      #id = qry.search.pop
      if res = @rdb.get(id)
        to_obj(res)
      else
        nil
      end
    end

    def to_obj(hsh)
      hsh["kind"] == "country" ? Country.new(hsh) : Spot.new(hsh)
    end

    def write(o)
      # pkey = @rdb.genuid
      if @rdb.put(o.gid, o.to_hash)
       # info "ok"
      else
        info "err #{rdb.ecode}"
      end
    end

    def count
      RDBQRY.new(@rdb).search.length
    end

    def close
      # close the database
      if !@rdb.close
        STDERR.printf("close error: %s\n", @rdb.errmsg(@rdb.ecode))
      end
    end

    def set_indexes
      #for index in indexes
      @rdb.setindex("gid", RDBTBL::ITOPT)
      @rdb.setindex("kind", RDBTBL::ITQGRAM)
      @rdb.setindex("name", RDBTBL::ITQGRAM)

      #end

    end



  end

end
