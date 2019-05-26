# frozen_string_literal: true

require "bcrypt"
require "i18n"
require "warden"
require 'logger'

require "hanami_id/version"
require "hanami_id/warden/strategy"
require "hanami_id/warden/app_helper"

module HanamiId
  class AuthError < StandardError; end

  class << self
    attr_accessor :logger
    attr_accessor :model_name
    attr_accessor :auth_app_name
    attr_accessor :failure_app
    attr_accessor :default_modules

    def configure
      yield self
    end

    def model
      @model ||= Module.const_get(classify @model_name)
    end

    def repository_name
      @repository_name ||= "#{@model_name}_repository"
    end

    def repository
      @repository ||= Module.const_get("#{classify @model_name}Repository")
    end

    def classify(string)
      Hanami::Utils::String.classify string
    end
  end

  # Defaults
  @logger = ::Logger.new(STDOUT)
  @model_name = 'user'
  @auth_app_name = 'Auth'
  @failure_app = lambda do |env|
    auth_app::Controllers::Session::New.new(
      login_failed_with: env["warden"].message
    ).call(env)
  end
  @default_modules = %w[sessions registrations].freeze
end

I18n.tap do |i18n|
  i18n.load_path << Dir[File.join File.expand_path("locales"), "*.yml"]
  i18n.enforce_available_locales = false
  i18n.default_locale = :en
end
