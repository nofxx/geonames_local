require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/geonames_local/adapters/mongodb')

describe Mongodb do

  SPECDB = "geonames_spec"

  before(:all) do
    #Mongodb.new({:dbname => SPECDB}).purge
  end

  def mock_spot(name)
    Spot.new("1\t#{name}\t#{name}\t\t-5.46874226086957\t-35.3565714695652\tA\tADM2\tBR\t22\t2407500\t6593\t\t12\t\t\t\tAmerica/Recife\t2006-12-17", :dump)
  end

  describe "Parsing Dump" do
    before do
      @mong = Mongodb.new({:dbname => SPECDB})
    end

    it "should find all" do
     @mong.all("cities").each { |c| p c["geom"]} #should eql([])
    end

    it "should store something" do
      @mong.insert("cities", {"id" => 7, "name" => "Sao Tome", "geom" => [5,5]})
      @mong.count("cities").should eql(1)
    end

    it "should store a spot" do
      @mong.insert("cities", mock_spot("Loco").to_hash)
      @mong.find("cities", 1)["name"].should eql("Loco")
    end

    it "should store geom" do
      @mong.insert("cities", {"id" => 8, "name" => "Sao Tome", "geom" => { "x" => 5, "y" => 5}})
      @mong.find("cities", 8)["geom"]["x"].should eql(5)
      @mong.find("cities", 8)["geom"]["y"].should eql(5)
    end

    it "should have some indexes" do
      @mong.index_info("cities").to_a.length.should eql(4)
    end

    it "should find geo" do
      p @mong.index_info('cities')
      @mong.insert("cities", {"id" => 9, "name" => "Sao Paulo", "geom" => [15,15]})
      @mong.insert("cities", {"id" => 10, "name" => "Sao Tome", "geom" => [5,5]})
      @mong.find_near("cities", -5, -35).should eql(1)
    end

    it "should find near" do
      p @mong.index_info('cities')
      @mong.insert("cities", {"id" => 9, "name" => "Sao Paulo", "geom" => [15,15]})
      @mong.insert("cities", {"id" => 10, "name" => "Sao Tome", "geom" => [5,5]})
      @mong.near("cities", -5, -35).should eql(1)
    end
  end
end
