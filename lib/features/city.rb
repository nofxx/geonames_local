class City
  attr_accessor :country, :province, :name

  def self.all
    qry.addcond(QCSTREQ, 'city')
  end
  
  
end
