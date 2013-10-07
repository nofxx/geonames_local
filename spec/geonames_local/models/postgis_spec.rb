# -*- coding: utf-8 -*-
# require File.expand_path(File.dirname(__FILE__) + '/../../spec_ar_helper')
# module Geonames
#   module Models
#     module AR
#       class User < ActiveRecord::Base
#         belongs_to :city
#       end
#     end
#   end
# end

# def brasil
#   Models::AR::Nation.find_or_create_by_name(:name => "Brazil", :abbr => "BR")
# end

# describe "Nation" do

#   it "should create countries" do
#     Models::AR::Nation.create(:name => "Chad", :abbr => "TD").should be_valid
#   end

#   it "should write to db" do
#     lambda do
#       Models::AR::Nation.create(:name => "Itália", :abbr => "IT")
#     end.should change(Models::AR::Nation, :count).by(1)
#   end

# end

# describe "Region" do

#   it "should be a class instance of ar" do
#     Models::AR::Region.new.should be_instance_of Models::AR::Region
#   end

#   it "should create" do
#     Models::AR::Region.create(:name => "Chadland", :nation => brasil).should be_valid
#   end
# end

# describe "City" do

#   it "should be a class instance of ar" do
#     Models::AR::City.new.should be_instance_of Models::AR::City
#   end

#   it "should create" do
#     Models::AR::City.create(:name => "Chadland", :nation => brasil).should be_valid
#   end
# end
# #  DatabaseCleaner.clean

# describe "Active Record Stuff" do

#   before do
#  #   DatabaseCleaner.clean
#     @br ||= brasil
#     Models::AR::City.create!("name" => "São Tomé", "geom" => [15,15], :nation => @br)
#     Models::AR::City.create!("name" => "Rock CIty", "geom" => [18,16], :nation => @br)
#   end

#   it "should record" do
#     Models::AR::City.count.should eql(2)
#   end

#   it "should create" do
#     user = Models::AR::User.new(:name => "Defendor")
#     user.city = Models::AR::City.first
#     user.save
#     Models::AR::User.first.city.name.should eql("São Tomé")
#   end
# end
