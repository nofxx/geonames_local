require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Tokyo" do

  it "should write down a spot" do
    t = Geonames::Tokyo.new('localhost', 1978)
    m = mock(Geonames::Spot, { :to_hash => { "lat" => 5.5 }})
    t.write(m)
  end

end
