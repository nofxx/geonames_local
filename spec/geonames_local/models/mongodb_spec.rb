# frozen_string_literal: true

require 'spec_helper'

# Initialize Geonames::Opt[:db] before requiring mongodb model to avoid nil error during Mongoid.configure
module Geonames
  Opt ||= {} # Ensure Opt is initialized
  Opt[:db] ||= { host: 'localhost:27017', name: 'geonames_test', options: {} }
end

require 'geonames_local/models/mongodb'
require 'geonames_local/features/spot'
require 'geonames_local/regions/abbr'

# Mock Mongoid models that would exist in a full application
class Nation
  attr_accessor :id, :abbr, :name

  def initialize(attrs)
    @id = attrs[:id]
    @abbr = attrs[:abbr]
    @name = attrs[:name]
  end

  def self.find_by(conditions); end # Stubbed in tests
end

class Region
  attr_accessor :id, :abbr, :name, :nation_id

  def initialize(attrs)
    @id = attrs[:id]
    @abbr = attrs[:abbr]
    @name = attrs[:name]
    @nation_id = attrs[:nation_id]
  end

  def self.find_by(conditions); end # Stubbed in tests

  def present?
    true
  end
end

class City
  # Define attributes if needed for parse_hood context
end

class Hood
  # Define attributes if needed
end

describe Geonames::Models::MongoWrapper do
  # The parsing methods are defined as class methods on MongoWrapper
  # So, we don't need to instantiate a loader.
  # let(:loader) { Geonames::Models::MongoWrapper } # Not needed for class methods

  before do
    Geonames::Opt[:verbose] = false # Suppress info messages
    Geonames::Opt[:locales] = ['en'] # Set default locales for tests
    Geonames::Cache[:alternate_names] = {} # Ensure cache is empty or controlled for translate method

    # Stub for Geonames::Regions::Abbr
    allow(Geonames::Regions::Abbr).to receive(:get_abbr).and_call_original
    allow(Geonames::Regions::Abbr).to receive(:get_abbr).with(anything, 'BR').and_return('BR_ABBR')
    allow(Geonames::Regions::Abbr).to receive(:get_abbr).with(anything, 'US').and_return('US_ABBR')
    allow(Geonames::Regions::Abbr).to receive(:get_abbr).with(anything, 'AG').and_return('AG_ABBR')
    allow(Geonames::Regions::Abbr).to receive(:get_abbr).with('Sao Paulo', 'BR').and_return('SP')
    allow(Geonames::Regions::Abbr).to receive(:get_abbr).with('California', 'US').and_return('CA')
    allow(Geonames::Regions::Abbr).to receive(:get_abbr).with('Saint George', 'AG').and_return('SG') # Example
  end

  describe '#parse_nation' do
    context 'with Brazil data' do
      let(:data) do
        "BR\tBRA\t076\tBR\tBrazil\tBrasilia\t8511965\t206135893\tSA\t.br\tBRL\tReal\t55\t^(\\d{5}-\\d{3})$\t^(\\d{5}-\\d{3})$\tpt-BR,es,en,fr\t3469034\tAR,BO,CO,GF,GY,PY,PE,SR,UY,VE"
      end
      it 'parses nation data correctly' do
        result = Geonames::Models::MongoWrapper.parse_nation(data)
        expect(result[:id]).to eq('BR')
        expect(result[:name_translations]).to eq({ 'en' => 'Brazil' })
        expect(result[:postal]).to eq('^(\\d{5}-\\d{3})$')
        expect(result[:cash]).to eq('BRL')
        expect(result[:gid]).to eq('3469034')
        expect(result[:souls]).to eq(206_135_893)
        expect(result[:abbr]).to eq('BR')
        expect(result[:code]).to eq('BRA')
        expect(result[:langs]).to eq(%w[pt-BR es en fr])
        expect(result[:phone]).to eq('55')
      end
    end

    context 'with US data' do
      let(:data) do
        "US\tUSA\t840\tUS\tUnited States\tWashington\t9629091\t327167434\tNA\t.us\tUSD\tDollar\t1\t^(\\d{5}(-\\d{4})?)$\t^(\\d{5}(-\\d{4})?)$\ten-US,es-US,haw,fr\t6252001\tCA,MX,CU"
      end
      it 'parses nation data correctly' do
        result = Geonames::Models::MongoWrapper.parse_nation(data)
        expect(result[:id]).to eq('US')
        expect(result[:name_translations]).to eq({ 'en' => 'United States' })
        expect(result[:souls]).to eq(327_167_434)
        expect(result[:abbr]).to eq('US')
        expect(result[:code]).to eq('USA')
        expect(result[:phone]).to eq('1')
      end
    end

    context 'with Antigua and Barbuda data' do
      let(:data) do
        "AG\tATG\t028\tAG\tAntigua and Barbuda\tSaint John's\t443\t97118\tNA\t.ag\tXCD\tDollar\t1-268\t\t\ten-AG\t3576396\t" # Corrected tabs for languages field
      end
      it 'parses nation data correctly' do
        result = Geonames::Models::MongoWrapper.parse_nation(data)
        expect(result[:id]).to eq('AG')
        expect(result[:name_translations]).to eq({ 'en' => 'Antigua and Barbuda' })
        expect(result[:souls]).to eq(97_118)
        expect(result[:abbr]).to eq('AG')
        expect(result[:code]).to eq('ATG')
        expect(result[:langs]).to eq(['en-AG'])
        expect(result[:phone]).to eq('1-268')
      end
    end
  end

  describe '#parse_region' do
    let(:mock_nation_br) { Nation.new(id: 'BR_ID', abbr: 'BR', name: 'Brazil') }
    let(:mock_nation_us) { Nation.new(id: 'US_ID', abbr: 'US', name: 'United States') }
    let(:mock_nation_ag) { Nation.new(id: 'AG_ID', abbr: 'AG', name: 'Antigua and Barbuda') }

    before do
      allow(Nation).to receive(:find_by).with(abbr: /BR/i).and_return(mock_nation_br)
      allow(Nation).to receive(:find_by).with(abbr: /US/i).and_return(mock_nation_us)
      allow(Nation).to receive(:find_by).with(abbr: /AG/i).and_return(mock_nation_ag)
    end

    context 'with Brazil data (Sao Paulo)' do
      # gid, name, ascii, alternates, lat, lon, feat_class, feat_code, nation, cc2, region (adm1), adm2, adm3, adm4, pop, ele, gtop, tz, up
      let(:spot_data_string) do
        "3448439\tSao Paulo\tSao Paulo\t\t-23.5329\t-46.6396\tA\tADM1\tBR\t\t27\t\t\t\t10021295\t\t\tAmerica/Sao_Paulo\t2019-09-05"
      end
      let(:spot) { Geonames::Spot.new(spot_data_string) }

      it 'parses region data correctly' do
        result = Geonames::Models::MongoWrapper.parse_region(spot)
        expect(result[:id]).to eq('3448439')
        expect(result[:name_translations]).to eq({ 'en' => 'Sao Paulo' })
        expect(result[:abbr]).to eq('SP')
        expect(result[:souls]).to eq(10_021_295)
        expect(result[:nation]).to eq(mock_nation_br)
        expect(result[:code]).to eq('27') # admin1_code
      end
    end

    context 'with US data (California)' do
      let(:spot_data_string) do
        "5332921\tCalifornia\tCalifornia\t\t37.2502\t-119.7513\tA\tADM1\tUS\t\tCA\t\t\t\t39538223\t\t\tAmerica/Los_Angeles\t2021-02-10"
      end
      let(:spot) { Geonames::Spot.new(spot_data_string) }

      it 'parses region data correctly' do
        result = Geonames::Models::MongoWrapper.parse_region(spot)
        expect(result[:id]).to eq('5332921')
        expect(result[:name_translations]).to eq({ 'en' => 'California' })
        expect(result[:abbr]).to eq('CA')
        expect(result[:souls]).to eq(39_538_223)
        expect(result[:nation]).to eq(mock_nation_us)
        expect(result[:code]).to eq('CA')
      end
    end

    context 'with Antigua and Barbuda data (Saint George)' do
      let(:spot_data_string) do
        "3576502\tSaint George\tSaint George\t\t17.0667\t-61.7833\tA\tADM1\tAG\t\t03\t\t\t\t7838\t\t\tAmerica/Antigua\t2013-07-09"
      end
      let(:spot) { Geonames::Spot.new(spot_data_string) }

      it 'parses region data correctly' do
        result = Geonames::Models::MongoWrapper.parse_region(spot)
        expect(result[:id]).to eq('3576502')
        expect(result[:name_translations]).to eq({ 'en' => 'Saint George' })
        expect(result[:abbr]).to eq('SG')
        expect(result[:souls]).to eq(7838)
        expect(result[:nation]).to eq(mock_nation_ag)
        expect(result[:code]).to eq('03')
      end
    end
  end

  describe '#parse_city' do
    let(:mock_nation_br) { Nation.new(id: 'BR_NATION_ID', abbr: 'BR', name: 'Brazil') }
    let(:mock_region_sp) { Region.new(id: 'SP_REGION_ID', abbr: 'SP', name: 'Sao Paulo', nation_id: 'BR_NATION_ID') }

    let(:mock_nation_us) { Nation.new(id: 'US_NATION_ID', abbr: 'US', name: 'United States') }
    let(:mock_region_ca) { Region.new(id: 'CA_REGION_ID', abbr: 'CA', name: 'California', nation_id: 'US_NATION_ID') }

    let(:mock_nation_ag) { Nation.new(id: 'AG_NATION_ID', abbr: 'AG', name: 'Antigua and Barbuda') }
    # Assuming region for St John's city
    let(:mock_region_ag_sj) do
      Region.new(id: 'AG_SJ_REGION_ID', abbr: 'ASJ', name: 'Saint John Parish', nation_id: 'AG_NATION_ID')
    end
    before do
      allow(Nation).to receive(:find_by).with(abbr: /BR/i).and_return(mock_nation_br)
      allow(Region).to receive(:find_by).with(code: '27', nation_id: 'BR_NATION_ID').and_return(mock_region_sp) # Sao Paulo city in SP (27)

      allow(Nation).to receive(:find_by).with(abbr: /US/i).and_return(mock_nation_us)
      allow(Region).to receive(:find_by).with(code: 'CA', nation_id: 'US_NATION_ID').and_return(mock_region_ca) # Los Angeles in CA

      allow(Nation).to receive(:find_by).with(abbr: /AG/i).and_return(mock_nation_ag)
      allow(Region).to receive(:find_by).with(code: '06', nation_id: 'AG_NATION_ID').and_return(mock_region_ag_sj) # St. John's city in St. John parish (06)
    end

    context 'with Brazil data (Sao Paulo city)' do
      # gid, name, ascii, alternates, lat, lon, feat_class, feat_code, nation, cc2, region (adm1), adm2 (spot.code), adm3, adm4, pop, ele, gtop, tz, up
      let(:spot_data_string) do
        "3448433\tSao Paulo\tSao Paulo\t\t-23.5505\t-46.6333\tP\tPPLC\tBR\t\t27\t3448433\t\t\t10021295\t\t\tAmerica/Sao_Paulo\t2020-03-15"
      end
      let(:spot) { Geonames::Spot.new(spot_data_string) } # spot.code will be adm2_code_str = "3448433"

      it 'parses city data correctly' do
        # Spot's @code is admin2_code, parse_city uses s.code (which is spot.code) for the output :code
        # Spot's @region is admin1_code
        result = Geonames::Models::MongoWrapper.parse_city(spot)
        expect(result[:id]).to eq('3448433')
        expect(result[:name_translations]).to eq({ 'en' => 'Sao Paulo' })
        expect(result[:code]).to eq('3448433') # feature code from spot (actually admin2_code in this Spot init)
        expect(result[:souls]).to eq(10_021_295)
        expect(result[:geom]).to eq([-46.6333, -23.5505])
        expect(result[:postal]).to be_nil # Zip not in this geonames string format
        expect(result[:region_id]).to eq('SP_REGION_ID')
        expect(result[:region_abbr]).to eq('SP')
      end
    end

    context 'with US data (Los Angeles city)' do
      let(:spot_data_string) do
        "5368361\tLos Angeles\tLos Angeles\tLA,Angels City\t34.0522\t-118.2437\tP\tPPLC\tUS\t\tCA\tLACOUNTY\t\t\t3971883\t\t\tAmerica/Los_Angeles\t2021-01-01"
      end
      let(:spot) { Geonames::Spot.new(spot_data_string) } # spot.code will be "LACOUNTY"

      it 'parses city data correctly' do
        result = Geonames::Models::MongoWrapper.parse_city(spot)
        expect(result[:id]).to eq('5368361')
        expect(result[:name_translations]).to eq({ 'en' => 'Los Angeles' })
        expect(result[:code]).to eq('LACOUNTY') # feature code from spot (admin2)
        expect(result[:souls]).to eq(3_971_883)
        expect(result[:geom]).to eq([-118.2437, 34.0522])
        expect(result[:region_id]).to eq('CA_REGION_ID')
        expect(result[:region_abbr]).to eq('CA')
      end
    end

    context 'with Antigua and Barbuda data (Saint John\'s city)' do
      # gid, name, ascii, alternates, lat, lon, feat_class, feat_code, nation, cc2, region (adm1), adm2, adm3, adm4, pop, ele, gtop, tz, up
      let(:spot_data_string) do
        "3576399\tSaint John's\tSaint John's\t\t17.1213\t-61.8447\tP\tPPLC\tAG\t\t06\tSJOHNSCITY\t\t\t22219\t\t\tAmerica/Antigua\t2018-06-30"
      end
      let(:spot) { Geonames::Spot.new(spot_data_string) } # spot.code will be "SJOHNSCITY"

      it 'parses city data correctly' do
        result = Geonames::Models::MongoWrapper.parse_city(spot)
        expect(result[:id]).to eq('3576399')
        expect(result[:name_translations]).to eq({ 'en' => "Saint John's" })
        expect(result[:code]).to eq('SJOHNSCITY') # feature code from spot (admin2)
        expect(result[:souls]).to eq(22_219)
        expect(result[:geom]).to eq([-61.8447, 17.1213])
        expect(result[:region_id]).to eq('AG_SJ_REGION_ID')
        expect(result[:region_abbr]).to eq('ASJ')
      end
    end
  end

  describe '#parse_hood' do
    # parse_hood is basic, mainly relies on spot attributes and translate
    # No complex lookups like Nation/Region.find_by are in the current parse_hood

    context 'with Brazil data (Vila Madalena hood)' do
      # gid, name, ascii, alternates, lat, lon, feat_class, feat_code, nation, cc2, region (adm1), adm2 (spot.code), adm3, adm4, pop, ele, gtop, tz, up
      let(:spot_data_string) do
        "12345\tVila Madalena\tVila Madalena\t\t-23.5500\t-46.7033\tP\tPPLX\tBR\t\t27\tVILAMADA\t\t\t50000\t\t\tAmerica/Sao_Paulo\t2022-01-01"
      end
      let(:spot) { Geonames::Spot.new(spot_data_string) } # spot.code will be "VILAMADA"

      it 'parses hood data correctly' do
        result = Geonames::Models::MongoWrapper.parse_hood(spot)
        expect(result[:id]).to eq('12345')
        expect(result[:name_translations]).to eq({ 'en' => 'Vila Madalena' })
        expect(result[:code]).to eq('VILAMADA') # feature code from spot (admin2)
        expect(result[:souls]).to eq(50_000)
        expect(result[:geom]).to eq([-46.7033, -23.5500])
        # Other fields like city_id, region_id are commented out in the actual parse_hood
      end
    end

    context 'with US data (Hollywood hood)' do
      let(:spot_data_string) do
        "5357527\tHollywood\tHollywood\t\t34.0983\t-118.3278\tP\tPPLX\tUS\t\tCA\tHOLLY\t\t\t167664\t\t\tAmerica/Los_Angeles\t2022-01-02"
      end
      let(:spot) { Geonames::Spot.new(spot_data_string) } # spot.code will be "HOLLY"

      it 'parses hood data correctly' do
        result = Geonames::Models::MongoWrapper.parse_hood(spot)
        expect(result[:id]).to eq('5357527')
        expect(result[:name_translations]).to eq({ 'en' => 'Hollywood' })
        expect(result[:code]).to eq('HOLLY') # feature code from spot (admin2)
        expect(result[:souls]).to eq(167_664)
        expect(result[:geom]).to eq([-118.3278, 34.0983])
      end
    end

    context 'with Antigua and Barbuda data (Codrington hood)' do
      # Using PPL as PPLX might not be common for smaller places
      let(:spot_data_string) do
        "3576605\tCodrington\tCodrington\t\t17.6333\t-61.8333\tP\tPPL\tAG\t\t01\tCODRING\t\t\t1325\t\t\tAmerica/Antigua\t2022-01-03"
      end
      let(:spot) { Geonames::Spot.new(spot_data_string) } # spot.code will be "CODRING"

      it 'parses hood data correctly' do
        result = Geonames::Models::MongoWrapper.parse_hood(spot)
        expect(result[:id]).to eq('3576605')
        expect(result[:name_translations]).to eq({ 'en' => 'Codrington' })
        expect(result[:code]).to eq('CODRING') # feature code from spot (admin2)
        expect(result[:souls]).to eq(1325)
        expect(result[:geom]).to eq([-61.8333, 17.6333])
      end
    end
  end
end
