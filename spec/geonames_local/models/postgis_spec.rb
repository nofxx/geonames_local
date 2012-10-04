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
#   Models::AR::Country.find_or_create_by_name(:name => "Brazil", :abbr => "BR")
# end

# describe "Country" do

#   it "should create countries" do
#     Models::AR::Country.create(:name => "Chad", :abbr => "TD").should be_valid
#   end

#   it "should write to db" do
#     lambda do
#       Models::AR::Country.create(:name => "Itália", :abbr => "IT")
#     end.should change(Models::AR::Country, :count).by(1)
#   end

# end

# describe "Province" do

#   it "should be a class instance of ar" do
#     Models::AR::Province.new.should be_instance_of Models::AR::Province
#   end

#   it "should create" do
#     Models::AR::Province.create(:name => "Chadland", :country => brasil).should be_valid
#   end
# end

# describe "City" do

#   it "should be a class instance of ar" do
#     Models::AR::City.new.should be_instance_of Models::AR::City
#   end

#   it "should create" do
#     Models::AR::City.create(:name => "Chadland", :country => brasil).should be_valid
#   end
# end
# #  DatabaseCleaner.clean

# describe "Active Record Stuff" do

#   before do
#  #   DatabaseCleaner.clean
#     @br ||= brasil
#     Models::AR::City.create!("name" => "São Tomé", "geom" => [15,15], :country => @br)
#     Models::AR::City.create!("name" => "Rock CIty", "geom" => [18,16], :country => @br)
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
