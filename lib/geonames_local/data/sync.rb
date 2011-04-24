module Geonames
  class Sync
    class << self

      def work!
        unify!
        write_to_store!
      end

      def load_adapter(name)
        begin
          require "geonames_local/adapters/#{name}"
          Geonames.class_eval(name.capitalize).new(Opt[:db])
        rescue LoadError
          puts "Can't find adapter #{name}"
          stop!
        end
      end

      def write_to_store!
        groups = Cache[:dump].group_by(&:kind)
        Cache[:provinces] = groups[:province]
        # ensure this order....
        do_write(groups[:province])
        do_write(groups[:city])
      end

      def do_write(values)
        return if values.empty?
        db = load_adapter(Opt[:store])
        key = values[0].table
        start = Time.now
        writt = 0
        min_pop = Opt[:min_pop]
        info "\nWriting #{values.length} #{key}..."
        info "\nWriting spots with pop > #{Opt[:min_pop]} hab." if min_pop
        values.each do |val|
          if min_pop
            next unless val.pop && val.pop.to_i >= min_pop
          end
          arg = val.respond_to?(:gid) ? [val.gid] : [val.name, true]
          unless db.find(val.table, *arg)
            db.insert(val.table, val)
            writt += 1
          end
        end
        total = Time.now - start
        info "#{writt} #{key} written in #{total} sec (#{(writt/total).to_i}/s)"
      end

      def unify!
        info "Join dump << zip"
        start = Time.now
        Cache[:dump].map! do |spot|
          if other = Cache[:zip].find { |d| d.code == spot.code }
            spot.zip = other.zip
            spot
          else
            spot
          end
        end
        info "Done. #{(Time.now-start).to_i}s"
      end

      def stop!
        puts "Closing Geonames..."
        exit
      end

    end

  end

end
