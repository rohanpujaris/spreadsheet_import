$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'spreadsheet_import'
require 'simplecov'
require 'active_record'
require 'database_cleaner'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
require 'schema'
Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |f| require f }

SimpleCov.start

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:all) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
