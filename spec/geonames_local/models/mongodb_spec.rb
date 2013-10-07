# -*- coding: utf-8 -*-
require "spec_helper"

# require 'geonames_local/models/mongodb'
# include Models::Mongo

# describe "City" do

#   # before(:all) do
#   #   Models::Mongo::City.insert("cities", {"id" => 9, "name" => "Sao Paulo", "geom" => [15,15]})
#   #   Models::Mongo::City.insert("cities", {"id" => 66, "name" => "Rock City", "geom" => [2,3]})
#   # end

#   after(:all) do
#     Mongodb.new({:dbname => "geonames_test"}).purge
#   end

#   it "should set a collection name" do
#     City.collection.should eql("cities")
#   end

#   it "should find all cities" do
#     Models::Mongo::City.all.should_not be_empty
#   end

#   it "should be a city instance" do
#     Models::Mongo::City.nearest(1,1).should be_instance_of(Models::Mongo::City)
#   end

#   it "should find city nearest point" do
#     Models::Mongo::City.nearest(1,1).name.should eql("Rock City")
#   end

#   it "should find by name" do
#     Models::Mongo::City.find_by_name("Rock")[0].name.should eql("Rock City")
#   end

#   it "should find by name" do
#     City.find_by_name("rock").first.name.should eql("Rock City")
#   end

# end
# require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
# require File.expand_path(File.dirname(__FILE__) + '/../../../lib/geonames_local/adapters/mongodb')

# describe "Mongo Models" do

#   SPECDB = "geonames_spec"

#   before() do
#     Mongodb.new({:dbname => SPECDB}).purge
#     @mong = Mongodb.new({:dbname => SPECDB})

#   end

#   def mock_spot(name)
#     Spot.new("1\t#{name}\t#{name}\t\t-5.46874226086957\t-35.3565714695652\tA\tADM2\tBR\t22\t2407500\t6593\t\t12\t\t\t\tAmerica/Recife\t2006-12-17", :dump)
#   end

#   describe "Parsing dump" do
#     before do
#       @mock_spot = mock("Spot")
#     end

#     it "should find all" do
#      @mong.all("cities").each { |c| p c["geom"]} #should eql([])
#     end

#     it "should store something" do
#       @mock_spot.should_receive(:to_hash).and_return({"id" => 7, "name" => "Sao Tome", "geom" => [5,5]})
#       @mong.insert("cities", @mock_spot)
#       @mong.count("cities").should eql(1)
#     end

#     it "should store a spot" do
#       @mong.insert("cities", mock_spot("Loco"))
#       @mong.find("cities", 1)["name"].should eql("Loco")
#     end

#     it "should store geom with sinusoidal projection" do
#       @mock_spot.should_receive(:to_hash).and_return({"id" => 8, "name" => "Sao Tome", "geom" => [5,8]})
#       @mong.insert("cities", @mock_spot)
#       @mong.find("cities", 8)["geom"][0].should be_within(0.01).of(4.95)
#       @mong.find("cities", 8)["geom"][1].should eql(8)
#     end

#     it "should have some indexes" do
#       @mong.index_info("cities").to_a.length.should eql(3)
#     end

#     describe "Finds" do

#       before() do
#         @mong.insert("cities", {"id" => 9, "name" => "Sao Paulo", "geom" => [15,15]})
#         @mong.insert("cities", {"id" => 10, "name" => "Sao Tome", "geom" => [-7,-34]})
#         @mong.insert("cities", {"id" => 11, "name" => "Sao Benedito", "geom" => [-9,-39]})
#       end

#       it "should make sure it's on the collection" do
#         @mong.count("cities").should eql(3)
#       end

#       it "should find geo" do
#         @mong.find_near("cities", -5, -35).first["name"].should eql("Sao Tome")
#         @mong.find_near("cities", -5, -35).first["geom"][0].should be_within(0.1).of(-5.80,)
#         @mong.find_near("cities", -5, -35).first["geom"][1].should eql(-34)
#       end

#       it "should find geo limited" do
#         @mong.find_near("cities", -5, -35, 1).length.should eql(1)
#       end

#       it "should find within box" do
#         @mong.find_within("cities", [[10, 10],[20, 20]]).length.should eql(1)
#         @mong.find_within("cities", [[10, 10],[20, 20]]).first["name"].should eql("Sao Paulo")
#       end

#       it "should find within tiny radius" do
#         @mong.find_within("cities", [[-6, -36], 2]).length.should eql(0)
#       end

#       it "should find within radius" do
#         @mong.find_within("cities", [[-6, -36], 3]).length.should eql(1)
#       end

#       it "should find within wider radius" do
#         @mong.find_within("cities", [[-6, -36], 5]).length.should eql(2)
#       end

#       it "should find within wider radius limited" do
#         @mong.find_within("cities", [[-6, -36], 5], 1).length.should eql(1)
#       end

#       it "should find geoNear" do
#         @mong.near("cities", -5, -35).first["dis"].should be_within(0.01).of(1.97)
#         @mong.near("cities", -5, -35).first["obj"]["name"].should eql("Sao Tome")
#       end

#       it "should find geoNear" do
#         @mong.near("cities", -5, -35).first["dis"].should be_within(0.01).of(1.97)
#         @mong.near("cities", -5, -35).first["obj"]["name"].should eql("Sao Tome")
#       end

#       it "should find geoNear limited" do
#         @mong.near("cities", -5, -35, 1).length.should eql(1)
#       end

#     end

#   end

# end
