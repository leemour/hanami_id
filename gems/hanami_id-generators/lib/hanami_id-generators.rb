# frozen_string_literal: true

require "hanami_id-generators/version"
require "hanami_id-generators/destroy/auth"
require "hanami_id-generators/generate/auth"

# TODO: remove pry
require "pry"

module HanamiId
  module Generators
  end

  class << self
    attr_accessor :logger

    def root
      @root ||= Dir.pwd.tap do |path|
        path.define_singleton_method(:join) do |*args|
          File.join path, *args
        end
      end
    end
  end

  @logger = Logger.new(STDOUT)
end
