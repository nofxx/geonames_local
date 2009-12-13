# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GeonamesLocal" do

  describe "Parsing" do
    before do
      @spot =  Geonames::Spot.new("6319037\tMaxaranguape\tMaxaranguape\t\t-5.46874226086957\t-35.3565714695652\tA\tADM2\tBR\t22\t2407500\t6593\t\t12\t\t\t\tAmerica/Recife\t2006-12-17")
    end

    it "should parse geoid integer" do
      @spot.geoname_id.should eql(6319037)
    end

    it "should parse name" do
      @spot.name.should eql("Maxaranguape")
      @spot.ascii.should eql("Maxaranguape")
    end

    it "should parse geostuff" do
      @spot.lat.should be_close(-5.4687, 0.001)
      @spot.y.should be_close(-5.4687, 0.001)
      @spot.lon.should be_close(-35.3565, 0.001)
    end

    it "should parse spot kind" do
      @spot.kind.should eql(:city)
    end

    it "should parse spot country" do
      @spot.country.should eql("BR")
    end

    it "shuold parse timezone" do
      @spot.tz.should eql("America/Recife")
    end

    it "should parse updated_at" do
      @spot.updated_at.should be_instance_of(Time)
      @spot.updated_at.day.should eql(17)
    end
  end

  describe "More Parseing" do
    before do
      @spot =  Geonames::Spot.new("3384862\tRiacho Zuza\tRiacho Zuza\t\t-9.4333333\t-37.6666667\tH\tSTMI\tBR\t\t02\t\t\t\t0\t\t241\tAmerica/Maceio\t1993-12-17\n")
    end

    it "should parse geoid integer" do
      @spot.geoname_id.should eql(3384862)
    end

    it "should parse name" do
      @spot.name.should eql("Riacho Zuza")
      @spot.ascii.should eql("Riacho Zuza")
    end

    it "should parse geostuff" do
      @spot.lat.should be_close(-9.4333333, 0.001)
      @spot.lon.should be_close(-37.6666667, 0.001)
    end

    it "should parse spot kind" do
      @spot.kind.should eql(:other)
    end

    it "should parse spot country" do
      @spot.country.should eql("BR")
    end

    it "shuold parse timezone" do
      @spot.tz.should eql("America/Maceio")
    end

    it "should parse updated_at" do
      @spot.updated_at.should be_instance_of(Time)
      @spot.updated_at.day.should eql(17)
    end
  end
end

# 6319037 Maxaranguape  Maxaranguape    -5.46874226086957 -35.3565714695652 A ADM2  BR    22  2407500     6593    12  America/Recife  2006-12-17
# 6319038 Mossoró Mossoro   -5.13813983076923 -37.2784795923077 A ADM2  BR    22  2408003     205822    33  America/Fortaleza 2006-12-17
# 6319039 Nísia Floresta  Nisia Floresta    -6.06240228440367 -35.1690981651376 A ADM2  BR    22  2408201     15817   15  America/Recife  2006-12-17

# 6319040 Paraú Parau   -5.73215878787879 -37.1366413030303 A ADM2  BR
# 22  2408706     4093    94  America/Fortaleza 2006-12-17
