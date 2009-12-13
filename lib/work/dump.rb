module Geonames
  class Worker
    URL = "http://download.geonames.org/export/dump"

    def self.get_file(code)
      code == "country" ? "countryInfo.txt" : "#{code.upcase}.zip"
    end

    def self.download(file)
      return if File.exists?("/tmp/" + file)
      `curl #{URL}/#{file} -o /tmp/#{file}`
    end

    def self.uncompress(file)
      info "Uncompressing #{file}"
      `unzip -qu /tmp/#{file} -d /tmp`
    end

    def self.parse_line(l)
      if Opt[:level] != "all"
        return unless l =~ /ADM\d/
      end
      return if l =~ /^#|^iso/i
      obj = l =~ /^\D/ ? Country.parse(l) : Spot.new(l)

    end

    def self.parse(file)
      db = Geonames::Tokyo.new
      red = 0
      start = Time.now
      File.open("/tmp/#{file.gsub("zip", "txt")}") do |f|
        while line = f.gets
          if record = parse_line(line)
            db.write record.to_hash
            red += 1
          end
        end
        total = Time.now - start
        info "#{red} entries parsed in #{total} sec (#{(red/total).to_i}/s)"
      end
    end


    def self.dump(codes=:all)
      if codes.respond_to? :each
        for code in codes
          file = get_file(code)
          download file
          uncompress file unless code == "country"
          parse file
        end
      end
    end


  end
end
