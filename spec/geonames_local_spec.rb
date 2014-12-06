# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Geonames do

  it 'should have a cache' do
    Cache.should be_instance_of(Hash)
  end

end
