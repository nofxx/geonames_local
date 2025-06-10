# frozen_string_literal: true

module Geonames
  class Dump
    attr_reader :data

    # Geonames base URL
    URL = 'http://download.geonames.org/export/'
    # Work temporary files
    TMP = '/tmp/geonames/'

    def initialize(target, kind)
      @kind = kind
      @data = []

      target.each { |n| work(n) } if target.respond_to? :each
      nations if target == :all
    end

    # Helper method to validate geonameid string format
    def self.geonameid_str_valid?(str)
      str.is_a?(String) && str.match?(/^\d+$/)
    end

    def self.load_alternate_names_to_cache(locales_to_keep = ['en'])
      Geonames.info('Loading alternate names to cache...')
      tmp_dir = File.join(TMP, 'dump') # Using 'dump' subdirectory for alternateNames
      zip_filename = 'alternateNamesV2.zip'
      txt_filename = 'alternateNamesV2.txt'
      zip_filepath = File.join(tmp_dir, zip_filename)
      txt_filepath = File.join(tmp_dir, txt_filename)

      Dir.mkdir(TMP) unless File.exist?(TMP)
      Dir.mkdir(tmp_dir) unless File.exist?(tmp_dir)

      # Download alternateNamesV2.zip if not already present
      if File.exist?(zip_filepath)
        Geonames.info("#{zip_filename} already downloaded.")
      else
        Geonames.info("Downloading #{zip_filename}...")
        # NOTE: The URL for alternateNamesV2.zip is under /dump/ not /export/
        download_url = "#{URL}dump/#{zip_filename}"
        cmd = "curl #{download_url} -o #{zip_filepath}"
        Geonames.info "Executing: #{cmd}"
        system(cmd)
        unless $?.success? && File.exist?(zip_filepath)
          Geonames.info "Failed to download #{zip_filename} from #{download_url}"
          return
        end
      end

      # Uncompress alternateNamesV2.txt if not already present or if zip is newer
      if !File.exist?(txt_filepath) || (File.exist?(zip_filepath) && File.mtime(zip_filepath) > File.mtime(txt_filepath))
        Geonames.info("Uncompressing #{zip_filename} to #{txt_filename}...")

        # Check if Zip::Error is defined. If not, rubyzip is not loaded correctly.
        unless defined?(Zip::Error)
          Geonames.info "CRITICAL: Zip::Error is not defined. The 'rubyzip' gem may not be loaded correctly or is corrupted. Cannot proceed with unzipping #{zip_filename}."
          Geonames.info "Please check your 'rubyzip' gem installation (version >= 2.0.0) and ensure it's compatible with your Ruby environment."
          return # Exit load_alternate_names_to_cache
        end

        begin
          Zip::File.open(zip_filepath) do |zip_file|
            entry = zip_file.find { |e| e.name == txt_filename }
            if entry
              entry.extract(txt_filepath) { true } # { true } overwrites
              Geonames.info("#{txt_filename} extracted successfully.")
            else
              Geonames.info("Could not find #{txt_filename} in #{zip_filepath}")
            end
          end
        rescue StandardError => e # This will catch Zip::Error if defined, or other StandardErrors
          Geonames.info "Failed to uncompress #{zip_filename}. Error type: #{e.class}, Message: #{e.message}"
          Geonames.info "Backtrace (first 5 lines): #{e.backtrace.take(5).join("\n")}"
          return # Exit load_alternate_names_to_cache on any unzipping error
        end
      else
        Geonames.info("#{txt_filename} already uncompressed and up-to-date.")
      end

      # Initialize cache if not already (safer)
      Geonames::Cache[:alternate_names] ||= {}

      # Parse alternateNamesV2.txt
      Geonames.info("Parsing #{txt_filename} for locales: #{locales_to_keep.join(', ')}...")
      count = 0
      skipped_invalid_gid = 0
      start_time = Time.now
      File.open(txt_filepath, 'r:UTF-8') do |f|
        while line = f.gets
          next if line.start_with?('#') # Skip comments

          parts = line.strip.split("\t")
          # alternateNameId, geonameid, isolanguage, alternate name,
          # isPreferredName, isShortName, isColloquial, isHistoric, from, to
          # We need geonameid (parts[1]), isolanguage (parts[2]), alternate name (parts[3])
          next if parts.length < 4

          geoname_id_str = parts[1]
          language_code = parts[2]
          alternate_name = parts[3]

          unless geonameid_str_valid?(geoname_id_str)
            # Geonames.info "Skipping alternate name due to invalid geonameid: #{geoname_id_str}"
            skipped_invalid_gid += 1
            next
          end
          geoname_id = geoname_id_str.to_i


          # Store if the language is one we care about and the name is not empty
          if locales_to_keep.include?(language_code) && alternate_name && !alternate_name.empty?
            is_preferred = parts[4] == '1' # isPreferredName is column 5 (index 4)

            Geonames::Cache[:alternate_names][geoname_id] ||= {}
            existing_entry = Geonames::Cache[:alternate_names][geoname_id][language_code]

            should_store = false
            if existing_entry.nil?
              should_store = true
            elsif is_preferred # New name is preferred, always overwrite
              should_store = true
            elsif !existing_entry[:preferred] # New name is not preferred, existing is also not preferred, overwrite (last wins for non-preferred)
              should_store = true
            end
            # If new is not preferred AND existing is preferred, should_store remains false (don't overwrite)

            if should_store
              Geonames::Cache[:alternate_names][geoname_id][language_code] = { name: alternate_name, preferred: is_preferred }
              count += 1 # Count unique geonameid/language pairs stored/updated
            end
          end
        end
      end
      end_time = Time.now
      Geonames.info("Finished parsing alternate names. Loaded #{count} names for #{Geonames::Cache[:alternate_names].keys.size} unique geoname IDs. Skipped #{skipped_invalid_gid} invalid GIDs. Took #{(end_time - start_time).round(2)}s.")
    rescue Errno::ENOENT
      Geonames.info("Failed to open #{txt_filepath} for parsing.")
    rescue StandardError => e
      Geonames.info("An error occurred during alternate names processing: #{e.message}")
      Geonames.info(e.backtrace.join("\n"))
    end

    def nations
      Geonames.info "\nDumping nation DB"
      file = get_file('nation')
      download file
      parse file
      Geonames.info 'Done nation DB'
    end

    def work(nation)
      Geonames.info "\nWorking on #{@kind} for #{nation}"
      file = get_file(nation)
      download file
      uncompress file
      parse file
    end

    def get_file(nation)
      nation == 'nation' ? 'countryInfo.txt' : "#{nation.upcase}.zip"
    end

    def download(file)
      Dir.mkdir(TMP) unless File.exist?(TMP)
      Dir.mkdir(TMP + @kind.to_s) unless File.exist?(TMP + @kind.to_s)
      fname = File.join(TMP, @kind.to_s, file) # Use File.join for robustness
      # Check if file exists and is not empty to prevent re-downloading corrupted/empty files.
      return if File.exist?(fname) && File.size?(fname)

      Geonames.info "Downloading #{file} to #{fname}..."
      cmd = "curl -fSsv #{URL}#{@kind}/#{file} -o #{fname}" # Added -fSsv for better error reporting from curl
      Geonames.info "Executing: #{cmd}"
      system(cmd)

      unless $?.success? && File.exist?(fname) && File.size?(fname)
        Geonames.info "ERROR: Failed to download #{file}. Curl exit status: #{$?.exitstatus}."
        Geonames.info "Command executed: #{cmd}"
        # Attempt to clean up potentially empty/corrupted file
        File.delete(fname) if File.exist?(fname)
        # The subsequent File.open in parse method will raise Errno::ENOENT if download failed,
        # which is handled there. Or, we could raise a specific error here.
        # For now, logging the error is an improvement.
        return false # Indicate failure
      end
      Geonames.info "#{file} downloaded successfully."
      true # Indicate success
    end

    def uncompress(file)
      Geonames.info "Uncompressing #{file}"
      `unzip -quo /tmp/geonames/#{@kind}/#{file} -d /tmp/geonames/#{@kind}`
    end

    def parse_line(line)
      # Skip comments (starting with '#') or ISO header lines (e.g., "ISO	ISO3	...")
      return nil if line.start_with?('#') || line.match?(/^iso/i)

      if @kind == :dump
        # This block handles lines from files processed with @kind = :dump.
        # This includes:
        # 1. 'countryInfo.txt': Its data lines (e.g., "US\tUSA...") start with non-digits.
        #    These should be returned as raw strings.
        # 2. Specific country files (e.g., 'US.txt', 'BR.txt'): Their data lines start with
        #    a digit (the geonameid). These are processed into Spot objects,
        #    potentially filtered by Opt[:level].

        return line if line.match?(/^\D/)
        # This line starts with a non-digit. It's assumed to be a data line
        # from 'countryInfo.txt' that should be returned raw.

        # This line starts with a digit, so it's from a specific country file (e.g., 'US.txt').
        # Apply filtering based on Opt[:level].
        if Opt[:level] != 'hood' && !line.match?(/ADM\d/)
          # If not at 'hood' level, and it's not an ADM line, skip it.
          return nil
        end
        # If at 'hood' level, or if it's an ADM line, it will proceed to Spot.new below.

      end

      # For @kind == :zip, or for @kind == :dump lines that passed the filters above.
      Spot.new(line, @kind)
    end

    def parse(file)
      File.open("/tmp/geonames/#{@kind}/#{file.gsub('zip', 'txt')}") do |f|
        while (line = f.gets)
          if (record = parse_line(line))
            @data << record
          end
        end
      end
    rescue Errno::ENOENT => e
      Geonames.info "Failed to download #{file}, skipping. #{e}"
    end
  end
end
