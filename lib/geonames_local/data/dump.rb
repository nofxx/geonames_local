module Geonames
  class Dump
    URL = "http://download.geonames.org/export/"
    TMP = "/tmp/geonames/"

    def initialize(codes, kind)
      @codes = codes
      @kind = kind
      @data = []
      if codes.respond_to? :each
        for code in codes
          work code
        end
      elsif codes == :nation
        nations
      end
    end

    def nations
      info "\nDumping nation database"
      file = get_file('nation')
      download file
      parse file
    end

    def work code
      info "\nWorking on #{@kind} for #{code}"
      file = get_file(code)
      download file
      uncompress file
      parse file
    end

    def data
      @data
    end

    def get_file(code)
      code == "nation" ? "countryInfo.txt" : "#{code.upcase}.zip"
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
          return l
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
            @data << record
            red += 1
          end
        end
        total = Time.now - start
        info "#{red} #{@kind} entries parsed in #{total} sec (#{(red/total).to_i}/s)"
      end
      rescue Errno::ENOENT => e
      info "Failed to download #{file}, skipping."
    end


  end

end
