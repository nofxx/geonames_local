module Geonames
  class Dump
    # Geonames base URL
    URL = "http://download.geonames.org/export/"
    # Work temporary files
    TMP = "/tmp/geonames/"

    def initialize(target, kind)
      @kind = kind
      @data = []
      if target.respond_to? :each
        target.each { |n| work(n) }
      elsif target == :all
        nations
      end
    end

    def nations
      info "\nDumping nation database"
      file = get_file('nation')
      download file
      parse file
    end

    def work nation
      info "\nWorking on #{@kind} for #{nation}"
      file = get_file(nation)
      download file
      uncompress file
      parse file
    end

    def data
      @data
    end

    def get_file(nation)
      nation == "nation" ? "countryInfo.txt" : "#{nation.upcase}.zip"
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
        info "#{red} #{@kind} spots parsed #{total}s (#{(red / total).to_i}/s)"
      end
      rescue Errno::ENOENT => e
      info "Failed to download #{file}, skipping. #{e}"
    end

  end

end
