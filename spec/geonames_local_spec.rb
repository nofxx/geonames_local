require 'spec_helper'
describe Geonames do
  it 'should have a cache' do
    expect(Cache).to be_instance_of(Hash)
  end
end
