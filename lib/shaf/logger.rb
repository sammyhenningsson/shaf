# frozen_string_literal: true

module Shaf
  class << self
    attr_writer :logger

    def log
      @logger ||= Logger.new('/dev/null')
    end
    alias logger log
  end
end
