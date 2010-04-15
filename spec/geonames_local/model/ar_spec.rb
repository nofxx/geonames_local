# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../spec_ar_helper')

class User < ActiveRecord::Base
  belongs_to :city
end


describe "Active Record Stuff" do


  it "should create" do
    user = User.new(:name => "Defendor")
    user.city = City.first
    p City.first
    user.save
    User.first.city.name.should eql("Sao Tome")
  end
end
