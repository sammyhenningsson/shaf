ENV['RACK_ENV'] = 'test'
require 'config/bootstrap'
require 'minitest/autorun'
require 'test/test_utils/payload'
require 'test/test_utils/integration'
require 'test/test_utils/model'
require 'test/test_utils/serializer'

class TestCase < Minitest::Test
  def run(*args, &block)
    pre_run
    options = {rollback: :always, auto_savepoint: true}
    DB.transaction(options) { super }
    post_run
    self
  end

  def pre_run
  end

  def post_run
  end
end

module Integration
  class TestCase < ::TestCase
    include TestUtils::Integration::Test
  end
end

module Model
  class TestCase < ::TestCase
    include TestUtils::Model::Test

    def pre_run
      @env = request.env
    end
  end
end

module Serializer
  class TestCase < ::TestCase
    include TestUtils::Serializer::Test
  end
end
