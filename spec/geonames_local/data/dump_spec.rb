require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Geonames::Dump do
  describe '.geonameid_str_valid?' do
    it 'returns true for valid geonameid strings' do
      expect(Geonames::Dump.geonameid_str_valid?('12345')).to be true
      expect(Geonames::Dump.geonameid_str_valid?('0')).to be true
    end

    it 'returns false for invalid geonameid strings' do
      expect(Geonames::Dump.geonameid_str_valid?('abc')).to be false
      expect(Geonames::Dump.geonameid_str_valid?('123a')).to be false
      expect(Geonames::Dump.geonameid_str_valid?('')).to be false
      expect(Geonames::Dump.geonameid_str_valid?(nil)).to be false
      expect(Geonames::Dump.geonameid_str_valid?('12.3')).to be false
      expect(Geonames::Dump.geonameid_str_valid?(' 123')).to be false # Contains space
    end

    it 'returns false for non-string inputs' do
      expect(Geonames::Dump.geonameid_str_valid?(12345)).to be false
      expect(Geonames::Dump.geonameid_str_valid?([])).to be false
      expect(Geonames::Dump.geonameid_str_valid?({})).to be false
    end
  end

  # Placeholder for more tests related to the Dump class
  # For example, testing the initialize method, download, parse, etc.
  # These would likely require mocking file operations and external calls.
end
