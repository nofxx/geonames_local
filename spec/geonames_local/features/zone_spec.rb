require 'spec_helper'

describe Zone do

  describe 'Parsing Dump' do

    before do
      @zone = Zone.new([:name, :null, :geom], "Copacabana\t2\t0106000020E6100000010000000103000020E6100000010000001B000000DE024322029645C0E3263B4536F736C06A78FF7D099745C05F4C17BC3AF836C016ECF835959745C0A6303C5AF6F836C031D79B0DEE9745C02A86A360EDF936C0BBC7A929259845C054515A9559FB36C0050527EF109845C02AD15A3969FC36C0A5705221BD9745C031151F7ACBFC36C0A96DC310049845C0055C26CBE0FC36C0C0FA3CDA6E9845C02424EED2F6FC36C08D80123FF49845C03C190018D7FB36C02E4C5C15199945C0A11ABD694CFB36C00D94B215269945C0F04B5E66CAFA36C03440A3EA169945C029ADE30D51FA36C082988494F89845C06DF6F65FD3F936C0E1CC3ABED39845C00B593959CFF836C0C0ED50117D9845C045937E53F2F736C03440A3EA169945C0CDFE644A93F636C0BA204AE9E29845C0C2EF96F233F636C08C60DFA8C29845C0A38B4DC61DF636C06DA128929D9845C03DE8AF4604F636C047CEF70F499845C08B67D19D49F636C0E87201390A9845C073BEF5F5B5F636C05F50930A799745C0B707094838F636C06CEAA05AAD9645C049A9FD439CF536C034760E48739645C0B9F4FBDC84F536C0F2A307AC159645C0CCEA3108E3F636C0DE024322029645C0E3263B4536F736C0")
    end

    it 'should parse code' do
      expect(@zone.name).to eql('Copacabana')
    end

    it 'should parse kind' do
      expect(@zone.kind).to eql(:zone)
    end

    it 'should parse geom' do
      expect(@zone.geom).to be_kind_of(GeoRuby::SimpleFeatures::MultiPolygon)
    end

    it 'should have 1 geometry' do
      expect(@zone.geom.size).to eq(1)
    end

    it 'should have 1 geometry polygon' do
      geom = @zone.geom.geometries[0]
      expect(geom).to be_kind_of(GeoRuby::SimpleFeatures::Polygon)
    end

    it 'should have 1 geometry polygon with n points' do
      expect(@zone.geom.geometries[0][0].size).to eq(27)
    end

  end

  describe 'Another parse' do
    before do
      @zone = Zone.new([:name, :null, :geom], "Botafogo\t4\t0106000020E6100000010000000103000020E610000001000000260000008C60DFA8C29845C0A38B4DC61DF636C0D68132D5E79845C090FADA554EF536C069D119B12A9945C0D857001102F436C0298D2075189945C0BFEDCBEBA8F336C049DBDD0FFA9845C0EEE2E7537BF336C0D68132D5E79845C0C2DCE6FB5FF336C0A761EE3BB99845C0FD7DA07637F336C048D58ABADF9845C061341567FBF136C0D5CD0D24649845C01D4DDC69AEF136C0106FC79E3B9845C058EE95E485F136C0739E6AE14F9845C043737CCFE3F036C0C10619C0459845C0466297DF9AF036C0BD63D9FE0A9845C0AF6F70421DF036C0A8E8BFE9689745C022C3C82715F036C0AF7A1ABB5A9745C08103515A72F036C0805AD6212C9745C0A04BBB9F39F036C03FFE0258109745C0E861C12D4AF036C0FD2EA4E8CC9645C08103515A72F036C03F62B834969645C0A9913A22AFF036C0C96B208E639645C0875AB5CC30F136C02DFC02077A9645C03E01065281F136C0BD3A35D49B9645C04CFB74214EF136C04048B7CBD99645C0F0F4ABBE6EF136C0ABD7DAF91F9745C0521060C417F236C083C8D321229745C0BC1081D776F236C009643E7BF99645C083E4C80ECAF236C0D16BCFB3BF9645C0EFBC652AD8F236C084595B73599645C07CA67AEF3AF336C0B1592EAC6B9645C0A3A74E6AB4F336C03DAE50A9189645C0D653696356F436C02127B0EE3C9645C070D22BCB62F536C034760E48739645C0B9F4FBDC84F536C06CEAA05AAD9645C049A9FD439CF536C05F50930A799745C0B707094838F636C0E87201390A9845C073BEF5F5B5F636C047CEF70F499845C08B67D19D49F636C06DA128929D9845C03DE8AF4604F636C08C60DFA8C29845C0A38B4DC61DF636C0")
    end

    it 'should parse code' do
      expect(@zone.name).to eql('Botafogo')
    end

    it 'should parse geom' do
      expect(@zone.geom).to be_kind_of(GeoRuby::SimpleFeatures::MultiPolygon)
    end

    it 'should have 1 geometry polygon with n points' do
      expect(@zone.geom.geometries[0][0].size).to eq(38)
    end

  end
end

# Copacabana\t2\t0106000020E6100000010000000103000020E6100000010000001B000000DE024322029645C0E3263B4536F736C06A78FF7D099745C05F4C17BC3AF836C016ECF835959745C0A6303C5AF6F836C031D79B0DEE9745C02A86A360EDF936C0BBC7A929259845C054515A9559FB36C0050527EF109845C02AD15A3969FC36C0A5705221BD9745C031151F7ACBFC36C0A96DC310049845C0055C26CBE0FC36C0C0FA3CDA6E9845C02424EED2F6FC36C08D80123FF49845C03C190018D7FB36C02E4C5C15199945C0A11ABD694CFB36C00D94B215269945C0F04B5E66CAFA36C03440A3EA169945C029ADE30D51FA36C082988494F89845C06DF6F65FD3F936C0E1CC3ABED39845C00B593959CFF836C0C0ED50117D9845C045937E53F2F736C03440A3EA169945C0CDFE644A93F636C0BA204AE9E29845C0C2EF96F233F636C08C60DFA8C29845C0A38B4DC61DF636C06DA128929D9845C03DE8AF4604F636C047CEF70F499845C08B67D19D49F636C0E87201390A9845C073BEF5F5B5F636C05F50930A799745C0B707094838F636C06CEAA05AAD9645C049A9FD439CF536C034760E48739645C0B9F4FBDC84F536C0F2A307AC159645C0CCEA3108E3F636C0DE024322029645C0E3263B4536F736C0
# Urca\t3\t0106000020E6100000010000000103000020E6100000010000001B0000002127B0EE3C9645C070D22BCB62F536C03DAE50A9189645C0D653696356F436C0B1592EAC6B9645C0A3A74E6AB4F336C084595B73599645C07CA67AEF3AF336C0E83F2850F59545C055D7AD3C9FF336C0DC146FFBDC9545C05C1D2A82ACF336C0D1AB3413C99545C05A5BAB15A8F336C01A57D1575A9545C091A56AC0D9F236C0C4ABD57A139545C0B6F9F5385CF236C0F455FDDCE09445C049FA5FF698F236C0C7552AA4CE9445C0A5A45A9178F236C06BAB2F09EF9445C061A3A4F0F2F136C041000765BA9445C0974CCB1059F136C03455C0E6919445C0A8A166B83CF136C051025D60269445C077C0834475F136C073CD3C4DED9345C0ADBF9312F6F036C0D74FB1CC5D9345C0980DE0176DF036C042ED293B4A9345C0620ED049ECF036C0B3A5A698B29345C0024AB15844F136C01A85C978D69345C00965B547C0F136C00ECD44B4AD9345C0A124EB3987F236C08E7D184B389345C04FF77B54ECF236C007B240C5319345C0C0AFF8B154F336C062F6BACCE69445C0CDE500904CF436C005FD244EEC9445C0DF38B3A39CF436C0E9BC9FD8169545C01F0AEC70AAF436C02127B0EE3C9645C070D22BCB62F536C0
# Botafogo\t4\t0106000020E6100000010000000103000020E610000001000000260000008C60DFA8C29845C0A38B4DC61DF636C0D68132D5E79845C090FADA554EF536C069D119B12A9945C0D857001102F436C0298D2075189945C0BFEDCBEBA8F336C049DBDD0FFA9845C0EEE2E7537BF336C0D68132D5E79845C0C2DCE6FB5FF336C0A761EE3BB99845C0FD7DA07637F336C048D58ABADF9845C061341567FBF136C0D5CD0D24649845C01D4DDC69AEF136C0106FC79E3B9845C058EE95E485F136C0739E6AE14F9845C043737CCFE3F036C0C10619C0459845C0466297DF9AF036C0BD63D9FE0A9845C0AF6F70421DF036C0A8E8BFE9689745C022C3C82715F036C0AF7A1ABB5A9745C08103515A72F036C0805AD6212C9745C0A04BBB9F39F036C03FFE0258109745C0E861C12D4AF036C0FD2EA4E8CC9645C08103515A72F036C03F62B834969645C0A9913A22AFF036C0C96B208E639645C0875AB5CC30F136C02DFC02077A9645C03E01065281F136C0BD3A35D49B9645C04CFB74214EF136C04048B7CBD99645C0F0F4ABBE6EF136C0ABD7DAF91F9745C0521060C417F236C083C8D321229745C0BC1081D776F236C009643E7BF99645C083E4C80ECAF236C0D16BCFB3BF9645C0EFBC652AD8F236C084595B73599645C07CA67AEF3AF336C0B1592EAC6B9645C0A3A74E6AB4F336C03DAE50A9189645C0D653696356F436C02127B0EE3C9645C070D22BCB62F536C034760E48739645C0B9F4FBDC84F536C06CEAA05AAD9645C049A9FD439CF536C05F50930A799745C0B707094838F636C0E87201390A9845C073BEF5F5B5F636C047CEF70F499845C08B67D19D49F636C06DA128929D9845C03DE8AF4604F636C08C60DFA8C29845C0A38B4DC61DF636C0
# Flamengo\t5\t0106000020E6100000010000000103000020E6100000010000001B0000003FFE0258109745C0E861C12D4AF036C0505F06F0EC9645C061922586A4EE36C0E340E3A0AF9645C0A4624A4E9AEE36C0E340E3A0AF9645C0732E602406EE36C0DF4D6D4F899645C069BD2F5CF7EC36C03CA0B8582D9645C069BD2F5CF7EC36C05115EC3A1D9645C080D8EC67A1EC36C0D4740B5B169645C09080E9BD7CEC36C028793995099645C00E3B47AB1BEC36C0E89B8A1E3A9645C0BB9E4A9D8CEB36C02486C343E39545C064A7A61173EB36C0920C18BF849545C0A21C245CDEEB36C0E1B59E7BED9545C08855DFE729EE36C0B8FE5B2C049645C0B95A3CEB64EF36C041A95EF9EE9545C00EE55931B3EF36C053FE6393C49545C03C68BEE2A2EF36C08F187850C19545C075C47C11D7EF36C038AF2FC38E9545C0FC8F5497DDEF36C038AF2FC38E9545C023970D2C3CF036C0EA3F166CBC9545C00D84B2039EF036C04DD4C1CA2A9645C0D1F66EC79DF136C0B261DB56579645C0B01C4273A9F136C02DFC02077A9645C03E01065281F136C0C96B208E639645C0875AB5CC30F136C03F62B834969645C0A9913A22AFF036C0FD2EA4E8CC9645C08103515A72F036C03FFE0258109745C0E861C12D4AF036C0
