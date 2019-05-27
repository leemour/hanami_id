# rubocop:disable Naming/FileName

# frozen_string_literal: true

require "hanami_id-generators/path"
require "hanami_id"

module HanamiId
  module Generators
    class << self
      attr_accessor :root
      attr_accessor :templates
    end

    @root = Path.new File.expand_path(File.dirname(__dir__))
    @templates = @root.join "lib", "hanami_id-generators", "templates"
  end
end

# TODO: remove pry
require "pry"

require "hanami_id-generators/version"
require "hanami_id-generators/destroy/auth"
require "hanami_id-generators/generate/auth"

# rubocop:enable Naming/FileName
