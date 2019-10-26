ENV['RAILS_ENV'] = 'test'
require_relative '../test/dummy/config/environment'
require 'rails/test_help'
require 'minitest/mock'
require 'factory_bot'

ActiveRecord::Migrator.migrations_paths = [
  File.expand_path('../test/dummy/db/migrate', __dir__)
]
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
FactoryBot.find_definitions

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  self.file_fixture_path = File.expand_path('fixtures/files', __dir__)
  parallelize(workers: 2)
end
