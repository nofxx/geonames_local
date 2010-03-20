# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../spec_ext_helper')
require "geo_ruby"

describe City do

  before(:all) do
    Adapter.insert("cities", {"id" => 9, "name" => "Sao Paulo", "geom" => [15,15]})
    Adapter.insert("cities", {"id" => 66, "name" => "Rock City", "geom" => [2,3]})
  end

  after(:all) do
    Mongodb.new({:dbname => "geonames"}).purge
  end

  it "should set a collection name" do
    City.collection.should eql("cities")
  end

  it "should find all cities" do
    City.all.should_not be_empty
  end

  it "should be a city instance" do
    City.nearest(1,1).should be_instance_of(City)
  end

  it "should find city nearest point" do
    City.nearest(1,1).name.should eql("Rock City")
  end

  it "should find by name" do
    City.find_by_name("Rock")[0].name.should eql("Rock City")
  end
end
