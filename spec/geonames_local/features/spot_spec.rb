# -*- coding: utf-8 -*-
require "spec_helper"
require "geo_ruby"

describe Spot do

  describe "Parsing Dump" do

    let(:spot) { Spot.new("6319037\tMaxaranguape\tMaxaranguape\t\t-5.46874226086957\t-35.3565714695652\tA\tADM2\tBR\t22\t2407500\t6593\t\t12\t\t\t\tAmerica/Recife\t2006-12-17", :dump) }

    it "should parse geoid integer" do
      spot.geoname_id.should eql(6319037)
      spot.gid.should eql(6319037)
    end

    it "should parse code" do
      spot.code.should eql("6593")
    end

    it "should parse region code" do
      spot.region.should eql("2407500")
    end

    it "should parse name" do
      spot.name.should eql("Maxaranguape")
      spot.ascii.should eql("Maxaranguape")
    end

    it "should parse geostuff" do
      spot.lat.should be_within(0.001).of(-5.4687)
      spot.y.should be_within(0.001).of(-5.4687)
      spot.lon.should be_within(0.001).of(-35.3565)
    end

    it "should parse spot kind" do
      spot.kind.should eql(:city)
    end

    it "should parse spot nation" do
      spot.nation.should eql("BR")
    end

    it "shuold parse timezone" do
      spot.tz.should eql("America/Recife")
    end

    it "should parse updated_at" do
      spot.updated_at.should be_instance_of(Time)
      spot.updated_at.day.should eql(17)
    end
  end

  describe "More Parsing" do

    let(:spot) { Geonames::Spot.new("3384862\tRiacho Zuza\tRiacho Zuza\t\t-9.4333333\t-37.6666667\tH\tSTMI\tBR\t\t02\t\t\t\t0\t\t241\tAmerica/Maceio\t1993-12-17\n", :dump) }

    it "should parse geoid integer" do
      spot.geoname_id.should eql(3384862)
    end

    it "should parse name" do
      spot.name.should eql("Riacho Zuza")
      spot.ascii.should eql("Riacho Zuza")
    end

    it "should parse geostuff" do
      spot.lat.should be_within(0.001).of(-9.4333333)
      spot.lon.should be_within(0.001).of(-37.6666667)
    end

    it "should parse spot kind" do
      spot.kind.should eql(:other)
    end

    it "should parse spot nation" do
      spot.nation.should eql("BR")
    end

    it "shuold parse timezone" do
      spot.tz.should eql("America/Maceio")
    end

    it "should parse updated_at" do
      spot.updated_at.should be_instance_of(Time)
      spot.updated_at.day.should eql(17)
    end
  end

  describe "Parsing Region" do

    let(:spot) { Geonames::Spot.new("3457153\tEstado de Minas Gerais\tEstado de Minas Gerais\tMinas,Minas Geraes,Minas Gerais\t-18.0\t-44.0\tA\tADM1\tBR\tBR\t15\t\t\t\t16672613\t\t1219\tAmerica/Sao_Paulo\t2007-05-15\n", :dump) }

    it "should be kind of region" do
      spot.kind.should eql(:region)
    end

    it "should parse geoid" do
    spot.geoname_id.should eql(3457153)
      spot.gid.should eql(3457153)
    end

    it "should parse code" do
      spot.code.should be_empty
    end

    it "should parse region code" do
      spot.region.should eql("15")
    end

    it "should create abbr" do
      spot.abbr.should eql("MG")
    end

    it "should parse name" do
      spot.name.should eql("Minas Gerais")
      spot.ascii.should eql("Estado de Minas Gerais")
    end

    it "should parse geostuff" do
      spot.lat.should be_within(0.001).of(-18.0)
      spot.lon.should be_within(0.001).of(-44.0)
    end

  end

  describe "Parsing City" do

    let(:spot) {  Spot.new "3386859\tTamboril\tTamboril\t\t-4.9931\t-40.26738\tA\tADM2\tBR\t\t06\t2313203\t\t\t25455\t\t401\tAmerica/Fortaleza\t2011-04-21" }

    it "should parse name" do
      spot.name.should eql("Tamboril")
    end

    it "should parse ascii name" do
      spot.name.should eql("Tamboril")
    end

    it "should parse x" do
      spot.x.should be_within(0.001).of(-40.26738)
    end

    it "should parse y" do
      spot.y.should be_within(0.001).of(-4.9931)
    end

    it "should parse tz" do
      spot.tz.should eql("America/Fortaleza")
    end

    it "should parse kind" do
      spot.kind.should eql(:city)
    end

    it "should parse nation" do
      spot.nation.should eql("BR")
    end

    it "should parse region" do
      spot.region.should eql("06")
    end

    it "should parse pop" do
      spot.pop.should eql("25455")
    end

  end

  describe "Parsing Big City" do

    let(:spot) {  Spot.new "6322846\tLondrina\tLondrina\t\t-23.58643\t-51.08739\tA\tADM2\tBR\t\t18\t4113700\t\t\t506645\t\t544\tAmerica/Sao_Paulo\t2011-04-21" }

    it "should parse name" do
      spot.name.should eql("Londrina")
    end

    it "should parse ascii name" do
      spot.name.should eql("Londrina")
    end

    it "should parse x" do
      spot.x.should be_within(0.001).of(-51.08739)
    end

    it "should parse y" do
      spot.y.should be_within(0.001).of(-23.58643)
    end

    it "should parse tz" do
      spot.tz.should eql("America/Sao_Paulo")
    end

    it "should parse kind" do
      spot.kind.should eql(:city)
    end

    it "should parse nation" do
      spot.nation.should eql("BR")
    end

    it "should parse region" do
      spot.region.should eql("18")
    end

    it "should parse pop" do
      spot.pop.should eql("506645")
    end


  end

  describe "Parsing Zip" do

    let(:spot) { Geonames::Spot.new("BR\t76375-000\tHidrolina\tGoias\t\t5209804\t29\t\t\t-14.7574\t-49.3596\t\n", :zip) }

    it "should parse zip oO" do
      spot.zip.should eql("76375-000")
    end

    it "should be a city" do
      spot.kind.should eql(:city)
    end

    it "should parse code" do
      spot.code.should eql("29")
    end

    it "should parse geoid integer" do
      spot.gid.should be_nil # eql(3384862)
    end

    it "should parse name" do
      spot.name.should eql("Hidrolina")
      spot.ascii.should be_nil # eql("Hidrolina")
    end

    it "should parse lat" do
      spot.lat.should be_within(0.001).of(-14.7574)
    end

    it "should parse lon" do
      spot.lon.should be_within(0.001).of(-49.3596)
    end

  end

  describe "From Hash" do

    let(:spot) { Spot.from_hash({"id" => 9, "name" => "Sao Rock", "geom" => [15,15], "kind" => "city", "nation" => "BR", "gid" => 13232, "tz" => "America/Foo", "ascii" => "Rock"}) }

    it "should be an spot" do
      spot.should be_instance_of Spot
    end

    it "should set the name" do
      spot.name.should eql("Sao Rock")
    end

    it "should set the geom" do
      spot.geom.should be_instance_of(GeoRuby::SimpleFeatures::Point)
      spot.geom.x.should eql(15)
    end

    it "should set the tz" do
      spot.tz.should eql("America/Foo")
    end

    it "should set the ascii" do
      spot.ascii.should eql("Rock")
    end

    it "should set the nation abbr" do
      spot.nation.should eql("BR")
    end

  end

end

# 6319037 Maxaranguape  Maxaranguape    -5.46874226086957 -35.3565714695652 A ADM2  BR    22  2407500     6593    12  America/Recife  2006-12-17
# 6319038 Mossoró Mossoro   -5.13813983076923 -37.2784795923077 A ADM2  BR    22  2408003     205822    33  America/Fortaleza 2006-12-17
# 6319039 Nísia Floresta  Nisia Floresta    -6.06240228440367 -35.1690981651376 A ADM2  BR    22  2408201     15817   15  America/Recife  2006-12-17
# 6319040 Paraú Parau   -5.73215878787879 -37.1366413030303 A ADM2  BR
# 22  2408706     4093    94  America/Fortaleza 2006-12-17

# "BR\t76375-000\tHidrolina\tGoias\t29\t\t5209804\t\t-14.7574\t-49.3596\t\n"
# "BR\t73920-000\tIaciara\tGoias\t29\t\t5209903\t\t-14.0819\t-46.7211\t\n"
# "BR\t75550-000\tInaciolândia\tGoias\t29\t\t5209937\t\t-18.4989\t-49.9016\t\n"
# "BR\t75955-000\tIndiara\tGoias\t29\t\t5209952\t^C\t-17.2276\t-49.9667\t\n"
# "IT\t89900\tVena\tCalabria\t\tVibo Valentia\tVV\t\t38.6578\t16.0602\t4\n"
# "IT\t89900\tVibo Marina\tCalabria\t\tVibo Valentia\tVV\t\t38.7143\t16.1135\t4\n"
# "IT\t89900\tTriparni\tCalabria\t\tVibo Valentia\tVV\t\t38.6839\t16.0672\t4\n"
# "IT\t89900\tPiscopio\tCalabria\t\tVibo Valentia\tVV\t\t38.6635\t16.112\t4\n"

# "3457153\tEstado de Minas Gerais\tEstado de Minas Gerais\tMinas,Minas Geraes,Minas Gerais\t-18.0\t-44.0\tA\tADM1\tBR\tBR\t15\t\t\t\t16672613\t\t1219\tAmerica/Sao_Paulo\t2007-05-15\n"
# "3457415\tEstado de Mato Grosso do Sul\tEstado de Mato Grosso do Sul\tEstado do Mato Grosso do Sul,Mato Grosso do Sul\t-21.0\t-55.0\tA\tADM1\tBR\t\t11\t\t\t\t2233378\t\t446\tAmerica/Campo_Grande\t2007-05-15\n"
# "3457419\tEstado de Mato Grosso\tEstado de Mato Grosso\tMato Grosso\t-13.0\t-56.0\tA\tADM1\tBR\t\t14\t\t\t\t2235832\t\t335\tAmerica/Cuiaba\t2007-05-15\n"
# "3462372\tEstado de Goiás\tEstado de Goias\tGoias,Goiaz,Goiás,Goyaz\t-15.5807107391621\t-49.63623046875\tA\tADM1\tBR\t\t29\t\t\t\t5521522\t\t695\tAmerica/Araguaina\t2009-10-04\n"
# "3463504\tDistrito Federal\tDistrito Federal\tDistrito Federal,Distrito Federal de Brasilia,Distrito Federal de Brasília,Futuro Distrito Federal,Municipio Federal,Novo Distrito Federal\t-15.75\t-47.75\tA\tADM1\tBR\t\t07\t\t\t\t1821946\t\t1035\tAmerica/Sao_Paulo\t2007-05-15\n"

# "3165361\tToscana\tToscana\tTaskana,Toscan-a,Toscana,Toscane,Toscann-a,Toskana,Toskania,Toskanio,Toskansko,Toskánsko,Toskāna,Toszkana,Toszkána,Tuscany,Tuschena,Tuschèna,Tuscia,toseukana ju,tosukana zhou,tuo si ka na,twsqnh,Таскана,Тоскана,טוסקנה,تسکانہ,ტოსკანა,トスカーナ州,托斯卡纳,토스카나 주\t43.4166667\t11.0\tA\tADM1\tIT\t\t16\t\t\t\t3718210\t\t249\tEurope/Rome\t2010-01-17\n"
# "3169778\tRegione Puglia\tRegione Puglia\tApulia,Apulie,Apulien,Apulië,Pouilles,Puglia\t41.25\t16.25\tA\tADM1\tIT\t\t13\t\t\t\t4021957\t\t95\tEurope/Rome\t2009-03-11\n"
# "3170831\tRegione Piemonte\tRegione Piemonte\tPedemons,Pedemontium,Piamonte,Piedmont,Piemont,Piemonte,Piémont,Piëmont,Regione Piemonte\t45.0\t8.0\tA\tADM1\tIT\t\t12\t\t\t\t4294081\t\t185\tEurope/Rome\t2008-08-18\n"
