require 'csv'

module Geonames
  class Export
    def initialize(data)
      info 'Starting export..'
      @data = data
    end

    def to_csv
      file = 'export.csv'
      info "Writing #{file} (#{@data.length} objects)"
      CSV.open('export.csv', 'w') do |csv|
        csv << @data[0].export_header
        @data.each { |o| csv << o.export }
      end
      info 'Export done.'
    end
  end
end
