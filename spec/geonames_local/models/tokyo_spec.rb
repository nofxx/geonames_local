require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Tokyo' do

  #   it "should write down a spot" do
  #     t = Geonames::Tokyo.new('localhost', 1978)
  #     m = mock(Geonames::Spot, { :gid => 888, :to_hash => { "gid" => 888, "kind" => "city", "lat" => 5.5 }})
  #     t.write(m)
  #   end

  #   it "should read it up" do
  #     t = Geonames::Tokyo.new('localhost', 1978)
  #     record = t.find(888)
  #     record.should be_instance_of Geonames::Spot
  #   end

  #   it "should not duplicate" do
  #     t = Geonames::Tokyo.new('localhost', 1978)
  #     t.all({ :gid => 888}).length.should eql(1)
  #   end

  #   it "should return all countries" do
  #     all = Geonames::Nation.all
  #     all.should be_instance_of Array
  #     all[0].should be_instance_of Geonames::Nation
  #     all[0].gid.should eql(1)
  #   end

end
