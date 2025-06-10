require 'spec_helper'

describe Geonames::Spot do
  # Mock the info method to prevent STDOUT during tests
  before do
    allow_any_instance_of(Geonames::Spot).to receive(:info)
    # Assume GeoRuby is not defined for these specific parsing tests
    # to simplify testing the parse_geom part if GeoRuby is a complex dependency to mock.
    # If GeoRuby::SimpleFeatures::Point creation is critical, it would need proper mocking or setup.
    hide_const('GeoRuby') if defined?(GeoRuby)
  end

  after do
    # Restore GeoRuby if it was hidden
    # This is a simple way; a more robust way might be needed if GeoRuby is loaded in complex ways.
    # For now, assuming it's either defined globally or not.
    # Re-define GeoRuby if it was originally defined. This is tricky.
    # A better approach for extensive testing would be to control its loading.
    # For this example, we'll skip complex restoration to keep it focused.
  end

  describe '#initialize with dump data (calls #parse)' do
    let(:raw_data_row) do
      [
        '6252001', # gid
        'United States', # name
        'United States', # ascii
        'USA,US,United States of America', # alternates
        '38.00000', # lat
        '-97.00000', # lon
        'A', # feature_class
        'PCLI', # feature_code (Independent political entity)
        'US', # nation
        '00', # cc2 (admin1_code for US states, not used directly here for region name)
        '00', # region (admin1_code, e.g., state FIPS code or other admin division)
        'ADM2_CODE_EXAMPLE', # admin2_code
        'ADM3_CODE_EXAMPLE', # adm3
        'ADM4_CODE_EXAMPLE', # adm4
        '327167434', # pop
        '236', # ele (elevation)
        '237', # gtop (digital elevation model)
        'America/New_York', # tz
        '2019-07-10' # up (updated_at)
      ].join("\t")
    end

    subject { Geonames::Spot.new(raw_data_row) } # kind defaults to nil, so parse() is called

    it 'correctly parses the geoname ID (gid)' do
      expect(subject.gid).to eq(6252001)
      expect(subject.geoname_id).to eq(6252001) # alias
    end

    it 'correctly parses the name' do
      expect(subject.name).to eq('United States')
    end

    it 'correctly parses the ASCII name' do
      expect(subject.ascii).to eq('United States')
    end

    it 'correctly parses latitude and longitude' do
      expect(subject.lat).to eq(38.0)
      expect(subject.lon).to eq(-97.0)
    end

    it 'correctly parses feature class and feature code' do
      expect(subject.feature_class).to eq('A')
      expect(subject.feature_code).to eq('PCLI')
    end

    it 'correctly parses nation code' do
      expect(subject.nation).to eq('US')
    end

    it 'correctly parses admin1 code into region' do
      expect(subject.region).to eq('00') # This is admin1_code from the input
    end

    it 'correctly parses admin2 code into code' do
      expect(subject.code).to eq('ADM2_CODE_EXAMPLE')
    end

    it 'correctly parses population' do
      expect(subject.pop).to eq(327167434)
    end

    it 'correctly parses timezone' do
      expect(subject.tz).to eq('America/New_York')
    end

    it 'correctly parses updated_at string into @up' do
      # The updated_at method itself converts this to Time object
      expect(subject.instance_variable_get(:@up)).to eq('2019-07-10')
    end

    it 'determines kind based on feature_code via human_code' do
      # PCLI is not ADM1, ADM2, ADM3, ADM4, so it should be :other
      expect(subject.kind).to eq(:other)
      expect(subject.table).to eq(:other) # alias
    end

    it 'extracts abbreviation from alternates' do
      expect(subject.abbr).to eq('USA') # Finds the first 2-3 letter uppercase string
    end

    it 'parses geom (assuming GeoRuby is not defined)' do
      expect(subject.geom).to eq({ lat: 38.0, lon: -97.0 })
    end

    context 'when feature_code is ADM1' do
      let(:adm1_data_row) do
        raw_data_row.gsub("PCLI", "ADM1") # Change feature_code to ADM1
      end
      subject { Geonames::Spot.new(adm1_data_row) }

      it 'sets kind to :region' do
        expect(subject.kind).to eq(:region)
      end

      it 'performs name gsub for region kind (Estado de -> )' do
        name_gsub_row = raw_data_row.gsub("PCLI", "ADM1").gsub("United States", "Estado de Foo")
        spot = Geonames::Spot.new(name_gsub_row)
        expect(spot.name).to eq('Foo') # "Estado de " should be removed
      end

       it 'performs name gsub for region kind (Federal District -> Distrito Federal)' do
        name_gsub_row = raw_data_row.gsub("PCLI", "ADM1").gsub("United States", "Federal District")
        spot = Geonames::Spot.new(name_gsub_row)
        expect(spot.name).to eq('Distrito Federal')
      end
    end

    context 'when feature_code is ADM2' do
      let(:adm2_data_row) do
        raw_data_row.gsub("PCLI", "ADM2") # Change feature_code to ADM2
      end
      subject { Geonames::Spot.new(adm2_data_row) }

      it 'sets kind to :city' do
        expect(subject.kind).to eq(:city)
      end
    end

    context 'when alternates string is nil or does not contain a valid abbreviation' do
      let(:no_abbr_row) do
        # gid, name, ascii, alternates, lat, lon, feat_class, feat_code, nation, cc2, region, admin2, adm3, adm4, pop, ele, gtop, tz, up
        ['1', 'Test Place', 'Test Place', 'long name,another long name', '10.0', '20.0', 'P', 'PPL', 'XY', '01', '01', '001', '', '', '100', '', '', 'UTC', '2023-01-01'].join("\t")
      end
      subject { Geonames::Spot.new(no_abbr_row) }

      it 'sets abbr to nil' do
        expect(subject.abbr).to be_nil
      end
    end
  end

  describe '#initialize with zip data (calls #parse_zip)' do
    let(:zip_data_row) do
      [
        'US', # nation (not used by parse_zip for @nation)
        '90210', # zip
        'Beverly Hills', # name
        'California', # admin name1
        'CA', # admin code1
        'Los Angeles', # admin name2
        '037', # admin code2 (becomes @code)
        '', # admin name3
        '', # admin code3
        '34.0901', # lat
        '-118.4065', # lon
        '1' # accuracy
      ].join("\t")
    end

    subject { Geonames::Spot.new(zip_data_row, :zip) }

    it 'correctly parses zip code' do
      expect(subject.zip).to eq('90210')
    end

    it 'correctly parses the name' do
      expect(subject.name).to eq('Beverly Hills')
    end

    it 'correctly parses admin2 code into @code' do
      expect(subject.code).to eq('037')
    end

    it 'correctly parses latitude and longitude' do
      expect(subject.lat).to eq(34.0901)
      expect(subject.lon).to eq(-118.4065)
    end

    it 'sets kind to :city' do
      expect(subject.kind).to eq(:city)
    end

    it 'parses geom (assuming GeoRuby is not defined)' do
      expect(subject.geom).to eq({ lat: 34.0901, lon: -118.4065 })
    end

    # Spot specific attributes not present in zip data should be nil
    it 'does not set nation from zip data directly' do
      expect(subject.nation).to be_nil
    end

    it 'does not set feature_class or feature_code from zip data' do
      expect(subject.feature_class).to be_nil
      expect(subject.feature_code).to be_nil
    end
  end

  describe '#updated_at' do
    it 'converts @up string to a Time object' do
      spot = Geonames::Spot.new("1\tName\tASCII\tALT\t0\t0\tP\tPPL\tUS\t00\t00\t\t\t\t0\t\t\tUTC\t2021-05-10")
      expect(spot.updated_at).to eq(Time.utc(2021, 5, 10))
    end

    it 'returns nil or raises error if @up is not a valid date string (behavior depends on Time.utc)' do
       # Test with invalid @up to see behavior, might raise ArgumentError
       spot = Geonames::Spot.new("1\tName\tASCII\tALT\t0\t0\tP\tPPL\tUS\t00\t00\t\t\t\t0\t\t\tUTC\tINVALID-DATE")
       expect { spot.updated_at }.to raise_error(ArgumentError) # or specific error Time.utc throws
    end
  end

  describe '#human_code' do
    let(:spot_instance) { Geonames::Spot.new } # Need an instance to call instance method

    it "returns :region for 'ADM1'" do
      expect(spot_instance.human_code('ADM1')).to eq(:region)
    end

    it "returns :city for 'ADM2'" do
      expect(spot_instance.human_code('ADM2')).to eq(:city)
    end

    it "returns :city for 'ADM3'" do
      expect(spot_instance.human_code('ADM3')).to eq(:city)
    end

    it "returns :city for 'ADM4'" do
      expect(spot_instance.human_code('ADM4')).to eq(:city)
    end

    it "returns :other for other codes" do
      expect(spot_instance.human_code('PCLI')).to eq(:other)
      expect(spot_instance.human_code('PPL')).to eq(:other)
      expect(spot_instance.human_code('')).to eq(:other)
      expect(spot_instance.human_code(nil)).to eq(:other) # Test nil case
    end
  end
end
