# frozen_string_literal: true

require 'spec_helper'
describe Geonames::SHP do
  before(:each) do
    # Initialize Geonames::Cache[:roads] with fresh data for each test run
    Geonames::Cache[:roads] = [
      Road.new(%i[name zone geom], "R DOUTOR VITAL BRASIL\t\\N\t0105000020E6100000010000000102000020E6100000020000009561DC0DA22B47C0EAB12D03CEF237C0136058FE7C2B47C0DE54A4C2D8F237C0"), # rubocop:disable Layout/LineLength
      Road.new(%i[name zone geom], "R DOUTOR VITAL BRASIL\t\\N\t0105000020E6100000010000000102000020E610000003000000136058FE7C2B47C0DE54A4C2D8F237C0094E7D20792B47C0CCB56801DAF237C0CDCAF6216F2B47C08F1B7E37DDF237C0"), # rubocop:disable Layout/LineLength
      Road.new(%i[name zone geom], "R DOUTOR VITAL BRASIL\t\\N\t0105000020E6100000010000000102000020E610000003000000A0F99CBB5D2B47C07A8F334DD8F237C019C6DD205A2B47C008E8BE9CD9F237C009C38025572B47C00DA5F622DAF237C0"), # rubocop:disable Layout/LineLength
      Road.new(%i[name zone geom], "R DOUTOR VITAL BRASIL\t\\N\t0105000020E6100000010000000102000020E61000000300000009C38025572B47C00DA5F622DAF237C0155454FD4A2B47C082397AFCDEF237C0FB213658382B47C053060E68E9F237C0") # rubocop:disable Layout/LineLength
    ]
    # Ensure Geonames::Opt is also set as SHP.new might depend on it
    Geonames::Opt[:type] = 'road'
  end

  # NOTE: The global setup of Geonames::Cache and Geonames::Opt (lines 5-13 in the original file)
  # are now effectively superseded by the before(:each) block for tests within this 'describe' scope.
  # If these global assignments were intended for other 'describe' blocks in this file (if any),
  # they might need to be adjusted or this before(:each) might need to be scoped more narrowly.
  # For now, assuming this 'describe Geonames::SHP' is the only one using this specific setup.

  it 'should merge two records linestrings' do
    # Store the original geometry EWKB and LineString count of the first road before modification
    original_first_road_geom_ewkb = nil
    original_first_road_linestring_count = 0
    if Geonames::Cache[:roads] && !Geonames::Cache[:roads].empty?
      first_road_geom = Geonames::Cache[:roads][0].geom
      original_first_road_geom_ewkb = first_road_geom.as_hex_ewkb
      if first_road_geom.respond_to?(:geometries)
        original_first_road_linestring_count = first_road_geom.geometries.length
      end
    end

    @s = Geonames::SHP.new(nil) # Initialize SHP; reduce! will use Geonames::Cache[:roads]
    merged_roads = @s.reduce!   # This returns an array where merged_roads[0] is the modified Cache[:roads][0]

    expect(merged_roads.length).to eql(1) # All roads with the same name should be merged into one

    # The merged geometry's EWKB should be different from the original EWKB of the first road
    expect(merged_roads[0].geom.as_hex_ewkb).not_to eql(original_first_road_geom_ewkb)

    # Verify that the number of LineStrings in the merged geometry is greater than the original first road's count,
    # and matches the total count from all roads in the test data.
    # The test data has 4 Road objects, each with a MultiLineString containing 1 LineString.
    # So, the merged MultiLineString should contain 4 LineStrings.
    if original_first_road_linestring_count > 0
      expect(merged_roads[0].geom.geometries.length).to be > original_first_road_linestring_count
    end
    expect(merged_roads[0].geom.geometries.length).to eql(4) # Total LineStrings from the 4 input roads
  end
end
