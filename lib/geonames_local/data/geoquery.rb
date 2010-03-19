module Geonames
  class Geoquery
    R = 1

    def self.point(tdb, x, y)
            qry = TDBQRY::new(tdb)
      qry.addcond("x", TDBQRY::QCNUMGE, minx.to_s())
      qry.addcond("x", TDBQRY::QCNUMLE, maxx.to_s())
      qry.addcond("y", TDBQRY::QCNUMGE, miny.to_s())
      qry.addcond("y", TDBQRY::QCNUMLE, maxy.to_s())
      qry.setorder("x", TDBQRY::QONUMASC)
      qry.setlimit(80)
    end


    def self.area(tdb, minx, maxx, miny, maxy)
      qry = TDBQRY::new(tdb)
      qry.addcond("x", TDBQRY::QCNUMGE, minx.to_s())
      qry.addcond("x", TDBQRY::QCNUMLE, maxx.to_s())
      qry.addcond("y", TDBQRY::QCNUMGE, miny.to_s())
      qry.addcond("y", TDBQRY::QCNUMLE, maxy.to_s())
      qry.setorder("x", TDBQRY::QONUMASC)

      res = qry.search
      info res.length # number of results found
      return res
    end


  end
end
