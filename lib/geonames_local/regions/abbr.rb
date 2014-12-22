module Geonames
  module Regions

    #
    # Geonames does not have region/state abbr..#fail!
    # This works 75% of the time in brazil heh
    def self.abbr(name)
      table = { # exceptions
        'Amapá'       => 'AP',
        'Mato Grosso' => 'MT',
        'Paraíba'     => 'PB',
        'Paraná'      => 'PR',
        'Roraima'     => 'RR'
      }[name]
      return table if table
      s = name.split(' ')
      if s.length > 1 # Foo Bar -> 'FB'
        [s[0][0].chr, s[-1][0].chr].map(&:upcase).join
      else  # Foobar -> 'FO'
        s[0][0..1].upcase
      end
    end
  end
end
