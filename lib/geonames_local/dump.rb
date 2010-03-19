module Geonames
  class Dump
    URL = "http://download.geonames.org/export/"
    TMP = "/tmp/geonames/"

    def initialize(codes, kind)
      @codes = codes
      @kind = kind
      if codes.respond_to? :each
        for code in codes
          info "\nWorking on #{kind} for #{code}"
          file = get_file(code)
          download file
          uncompress file unless code == "country"
          parse file
        end
      end

    end

    def get_file(code)
      code == "country" ? "countryInfo.txt" : "#{code.upcase}.zip"
    end

    def download(file)
      Dir.mkdir(TMP) unless File.exists?(TMP)
      Dir.mkdir(TMP + @kind.to_s) unless File.exists?(TMP + @kind.to_s)
      fname = TMP + "#{@kind}/#{file}"
      return if File.exists?(fname)
      `curl #{URL}/#{@kind}/#{file} -o #{fname}`
    end

    def uncompress(file)
      info "Uncompressing #{file}"
      `unzip -quo /tmp/geonames/#{@kind}/#{file} -d /tmp/geonames/#{@kind}`
    end

    def parse_line(l)
      return if l =~ /^#|^iso/i
      if @kind == :dump
        if l =~ /^\D/
          Country.parse(l)
        else
          if Opt[:level] != "all"
            return unless l =~ /ADM\d/ # ADM2 => cities
          end
        end
      end
      Spot.new(l, @kind)
    end

    def parse(file)
      red = 0
      start = Time.now
      File.open("/tmp/geonames/#{@kind}/#{file.gsub("zip", "txt")}") do |f|
        while line = f.gets
          if record = parse_line(line)
            Cache[@kind] << record
            red += 1
          end
        end
        total = Time.now - start
        info "#{red} #{@kind} entries parsed in #{total} sec (#{(red/total).to_i}/s)"
      end
      rescue Errno::ENOENT => e
      info "Failed to download #{file}, skipping."
    end


    def self.work(codes=:all, kind=:dump)
      new(codes, kind)
    end

  end

end
