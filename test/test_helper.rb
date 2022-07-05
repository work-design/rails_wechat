ENV['RAILS_ENV'] = 'test'
require_relative 'dummy/config/environment'
require 'rails/test_help'
require 'minitest/mock'

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

class ActiveSupport::TestCase
  self.file_fixture_path = File.expand_path('fixtures/files', __dir__)
  parallelize(workers: 2)
end
