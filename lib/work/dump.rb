module Geonames
  class Worker
    URL = "http://download.geonames.org/export/dump"

    def self.download(code)
      file = "/tmp/#{code.upcase}.zip"
      return if File.exists? file
      `curl #{URL}/#{code.upcase}.zip -o #{file}`
    end

    def self.uncompress(code)
      info "Uncompressing #{code}"
      `unzip -qu /tmp/#{code.upcase}.zip -d /tmp`
    end


    def self.parse(code, filter=:main)
      db = Geonames::Tokyo.new
      red = 0
      start = Time.now
      File.open("/tmp/#{code.upcase}.txt") do |f|
        while line = f.gets
          if filter != :all
            next unless line =~ /ADM\d/
          end
          red += 1
          db.write Spot.new(line.chomp).to_hash unless line =~ /^#|^iso/i
            #info "So far #{red} #{red/10}/s"
          # end
        end
        total = Time.now - start
        info "#{red} entries parsed in #{total} sec (#{(red/total).to_i}/s)"
      end
    end


    def self.dump(codes=:all)
      if codes.respond_to? :each
        for code in codes
          download code
          uncompress code
          parse code
        end
      end
    end


  end
end
