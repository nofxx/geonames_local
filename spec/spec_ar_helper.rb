$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec'
require 'spec/autorun'
require 'active_record'
require 'postgis_adapter'
require 'geonames_ar'

ActiveRecord::Base.logger = $logger
ActiveRecord::Base.establish_connection({ :adapter => "postgresql",
                                          :database => "geonames_ar",
                                          :username => "postgres",
                                          :password => "" })

ActiveRecord::Schema.define() do


  create_table :users, :force => true do |t|
    t.string              :name, :nick, :limit => 100
    t.string              :email
    t.integer             :code
    t.references          :city
  end
   create_table :cities, :force => true  do |t|
      t.references :country, :null => false
      t.references :province
      t.string  :name, :null => false
      t.point   :geom,   :srid => 4326
      t.integer :gid, :zip
    end

    create_table :provinces, :force => true do |t|
      t.references :country, :null => false
      t.string :name, :null => false
      t.string :abbr, :limit => 2, :null => false
      t.integer :gid
    end

    create_table :countries, :force => true do |t|
      t.string :name, :limit => 30, :null => false
      t.string :abbr, :limit => 2,  :null => false
    end

    add_index :cities, :name
    add_index :cities, :gid
    add_index :cities, :zip
    add_index :cities, :country_id
    add_index :cities, :province_id
    add_index :cities, :geom, :spatial => true
    add_index :provinces, :name
    add_index :provinces, :abbr
    add_index :provinces, :gid
    add_index :provinces, :country_id

end
