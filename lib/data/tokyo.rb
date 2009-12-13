require 'tokyotyrant'

module Geonames
  class Tokyo
    include TokyoTyrant

    def initialize(addr = 'localhost', port=1978)
      @rdb = RDBTBL.new
      @rdb.open(addr, port)
    end

    def write(o)
      pkey = @rdb.genuid
      if @rdb.put(pkey, o.to_hash)
       # info "ok"
      else
        info "err #{rdb.ecode}"
      end

    end




  end

end
