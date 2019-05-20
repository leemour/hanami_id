# frozen_string_literal: true

require "bcrypt"
require "i18n"
require "warden"

require "hanami_id/version"
require "hanami_id/warden/strategy"
require "hanami_id/warden/app_helper"

module HanamiId
  class AuthError < StandardError; end

  class << self
    attr_accessor :logger
    attr_accessor :model
    attr_accessor :auth_app
    attr_accessor :failure_app

    def configure
      yield self
    end

    def repository
      @repository ||= Module.const_get(
        "#{Hanami::Utils::String.classify @model}Repository"
      )
    end
  end

  # Defaults
  @logger = Logger.new(STDOUT)
  @model = :user
  @auth_app = :Auth
  @failure_app = lambda do |env|
    auth_app::Controllers::Session::New.new(
      login_failed_with: env["warden"].message
    ).call(env)
  end
end

I18n.tap do |i18n|
  i18n.load_path << Dir[File.join File.expand_path("locales"), "*.yml"]
  i18n.enforce_available_locales = false
  i18n.default_locale = :en
end
