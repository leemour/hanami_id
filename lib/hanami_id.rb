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

  @logger = Logger.new(STDOUT)
  @failure_app = lambda do |env|
    Web::Controllers::Session::New.new(
      login_failed_with: env["warden"].message
    ).call(env)
  end
end

I18n.load_path << Dir[File.join File.expand_path("locales"), "*.yml"]
I18n.enforce_available_locales = false
I18n.default_locale = :en
