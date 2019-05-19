# frozen_string_literal: true

require 'hanami_id-generators/version'
require 'hanami_id-generators/destroy/auth'
require 'hanami_id-generators/generate/auth'

# TODO: remove pry
require 'pry'

module HanamiId
  module Generators
  end

  class << self
    attr_accessor :logger
  end

  @logger = Logger.new(STDOUT)
end
