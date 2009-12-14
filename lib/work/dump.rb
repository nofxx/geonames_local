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
      `unzip -quo /tmp/#{file} -d /tmp`
    end

    def self.parse_line(l)
      return if l =~ /^#|^iso/i
      if l =~ /^\D/
        Country.parse(l)
      else
        if Opt[:level] != "all"
          return unless l =~ /ADM\d/
        end
        Spot.new(l)
      end
    end

    def self.parse(file)
      p Opt
      db = Geonames::Tokyo.new(Opt[:tyrant])
      red = 0
      start = Time.now
      File.open("/tmp/#{file.gsub("zip", "txt")}") do |f|
        while line = f.gets
          if record = parse_line(line)
            db.write record unless db.find record.gid
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
