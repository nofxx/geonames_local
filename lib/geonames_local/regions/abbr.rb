require 'yaml'

module Geonames
  module Regions
    module Abbr
      # Path to the YML files for region abbreviations.
      ABBR_DATA_PATH = File.expand_path('../region/abbr', __dir__)
      @loaded_abbrs = nil

      # Loads all .yml files from the ABBR_DATA_PATH.
      # The data is structured as:
      # {
      #   "us" => { "CA" => "California", "NY" => "New York", ... },
      #   "br" => { "SP" => "São Paulo", "MG" => "Minas Gerais", ... }
      # }
      # Keys are lowercase country codes, then uppercase region abbr, value is full region name.
      def self.load_abbreviations
        return @loaded_abbrs if @loaded_abbrs

        @loaded_abbrs = {}
        Dir.glob(File.join(ABBR_DATA_PATH, '*.yml')).each do |yaml_file|
          begin
            data = YAML.load_file(yaml_file)
            if data.is_a?(Hash) && data.keys.size == 1
              country_code = data.keys.first.to_s.downcase
              if data[data.keys.first].is_a?(Hash)
                @loaded_abbrs[country_code] ||= {}
                # Ensure region abbreviations (keys) are uppercase
                data[data.keys.first].each do |abbr, name|
                  @loaded_abbrs[country_code][abbr.to_s.upcase] = name.to_s
                end
              else
                warn "[Geonames::Regions::Abbr] Skipping invalid YML structure (expected hash for country data) in #{yaml_file}"
              end
            else
              warn "[Geonames::Regions::Abbr] Skipping invalid YML structure (expected single country key) in #{yaml_file}"
            end
          rescue StandardError => e
            warn "[Geonames::Regions::Abbr] Error loading YML file #{yaml_file}: #{e.message}"
          end
        end
        @loaded_abbrs
      end

      # Finds the abbreviation for a given region name and country code.
      #
      # @param region_name [String] The full name of the region (e.g., "California", "Minas Gerais").
      #        This name must exactly match the value in the corresponding YML file.
      # @param country_code [String, Symbol] The ISO 3166-1 alpha-2 country code (e.g., "us", "br").
      # @return [String, nil] The 2-letter abbreviation (uppercased), or nil if not found.
      def self.find_for_region(region_name, country_code)
        abbreviations = load_abbreviations
        return nil if region_name.to_s.empty? || country_code.to_s.empty?

        country_key = country_code.to_s.downcase
        country_abbrs = abbreviations[country_key]

        return nil unless country_abbrs.is_a?(Hash)

        # Find the key (abbr) where the value matches the provided region_name
        # Case-insensitive comparison for region_name for more robustness,
        # though YML values should ideally be exact.
        found_abbr = country_abbrs.find { |_abbr, name| name.to_s.casecmp(region_name.to_s) == 0 }
        found_abbr ? found_abbr.first : nil # Returns the abbreviation (key)
      end

      # Fallback heuristic for generating an abbreviation if not found in YML.
      # This is the original logic.
      #
      # @param name [String] The full name of the region.
      # @return [String] A 2-letter (usually) uppercased abbreviation.
      def self.heuristic_abbr(name)
        return nil if name.to_s.empty?
        # Original exceptions, could be moved to a yml if desired for consistency
        # For now, keeping them here as a direct fallback if YML lookup fails.
        # This part might be redundant if YMLs are comprehensive.
        table = {
          'Amapá'       => 'AP',
          'Mato Grosso' => 'MT',
          'Paraíba'     => 'PB',
          'Paraná'      => 'PR',
          'Roraima'     => 'RR'
        }[name]
        return table if table

        s = name.to_s.split(' ')
        if s.length > 1 # Foo Bar -> 'FB'
          [s[0][0].chr, s[-1][0].chr].map(&:upcase).join
        else  # Foobar -> 'FO'
          s[0][0..1].upcase
        end
      end

      # Primary method to get an abbreviation.
      # Tries YML lookup first, then falls back to heuristic.
      #
      # @param region_name [String] The full name of the region.
      # @param country_code [String, Symbol] The ISO 3166-1 alpha-2 country code.
      # @return [String, nil] The abbreviation or nil.
      def self.get_abbr(region_name, country_code)
        abbr = find_for_region(region_name, country_code)
        abbr || heuristic_abbr(region_name)
      end

    end
  end
end
