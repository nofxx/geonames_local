# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

require 'geonames_local/models/mongodb'
include Models::Mongo

describe "City" do

  # before(:all) do
  #   Models::Mongo::City.insert("cities", {"id" => 9, "name" => "Sao Paulo", "geom" => [15,15]})
  #   Models::Mongo::City.insert("cities", {"id" => 66, "name" => "Rock City", "geom" => [2,3]})
  # end

  after(:all) do
    Mongodb.new({:dbname => "geonames_test"}).purge
  end

  it "should set a collection name" do
    City.collection.should eql("cities")
  end

  it "should find all cities" do
    Models::Mongo::City.all.should_not be_empty
  end

  it "should be a city instance" do
    Models::Mongo::City.nearest(1,1).should be_instance_of(Models::Mongo::City)
  end

  it "should find city nearest point" do
    Models::Mongo::City.nearest(1,1).name.should eql("Rock City")
  end

  it "should find by name" do
    Models::Mongo::City.find_by_name("Rock")[0].name.should eql("Rock City")
  end

  it "should find by name" do
    City.find_by_name("rock").first.name.should eql("Rock City")
  end

end
