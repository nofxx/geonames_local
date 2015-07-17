# $LOAD_PATH.unshift(File.dirname(__FILE__))
# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
# require 'rspec'
# require 'rspec/autorun'
# require 'active_record'
# require 'postgis_adapter'
# require 'database_cleaner'
# Opt[:db] = { :adapter => "postgresql",
#                                           :database => "geonames_ar",
#                                           :username => "postgres",
#                                           :password => "" }
# require 'geonames_ar'
# include Geonames::Models

#  # DatabaseCleaner.strategy = :truncation

# ActiveRecord::Base.logger = $logger

# begin
#   ActiveRecord::Base.establish_connection(Opt[:db])
#   ActiveRecord::Migration.verbose = false
#   PG_VERSION = ActiveRecord::Base.connection.select_value("SELECT version()").scan(/PostgreSQL ([\d\.]*)/)[0][0]

#   puts "Running against PostgreSQL #{PG_VERSION}"

# rescue PGError
#   puts "Test DB not found, creating one for you..."
#   `createdb -U postgres geonames_ar -T template_postgis`
#   puts "Done. Please run spec again."
#   exit
# end

# ActiveRecord::Schema.define() do

#   create_table :users, :force => true do |t|
#     t.string              :name, :nick, :limit => 100
#     t.string              :email
#     t.integer             :code
#     t.references          :city
#   end

#   create_table :cities, :force => true  do |t|
#     t.references :country, :null => false
#     t.references :region
#     t.string  :name, :null => false
#     t.point   :geom,   :srid => 4326
#     t.integer :gid, :zip
#   end

#   create_table :regions, :force => true do |t|
#     t.references :country, :null => false
#     t.string :name, :null => false
#     t.string :abbr, :limit => 3
#     t.integer :gid
#   end

#   create_table :countries, :force => true do |t|
#     t.string :name, :limit => 30, :null => false
#     t.string :abbr, :limit => 2,  :null => false
#   end

#   add_index :cities, :name
#   add_index :cities, :gid
#   add_index :cities, :postal
#   add_index :cities, :country_id
#   add_index :cities, :region_id
#   add_index :cities, :geom, :spatial => true
#   add_index :regions, :name
#   add_index :regions, :abbr
#   add_index :regions, :gid
#   add_index :regions, :country_id
#   add_index :countries, :abbr, :unique => true
#   add_index :countries, :name, :unique => true

# end

# RSpec.configure do |c|

#   c.before(:suite) do
#     DatabaseCleaner.strategy = :transaction
#     DatabaseCleaner.clean_with(:truncation,
#     {:except => %w[geography_columns schema_migrations spatial_ref_sys geometry_columns]})
#   end

#   c.before(:each) do
#     DatabaseCleaner.start
#   end

#   c.after(:each) do
#     DatabaseCleaner.clean
#   end

# end
