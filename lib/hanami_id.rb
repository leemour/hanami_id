# frozen_string_literal: true

require "bcrypt"
require "i18n"
require "logger"
require "warden"

require "hanami_id/version"
require "hanami_id/warden/strategy"
require "hanami_id/warden/app_helper"
require "hanami_id/warden/session"
require "hanami_id/password"

module HanamiId
  MODES = %w[standalone project].freeze
  MODULES = %w[sessions registrations].freeze
  STRATEGIES = %i[password].freeze

  class AuthError < StandardError; end

  class << self
    attr_accessor :logger
    attr_accessor :model_name
    attr_accessor :app_name
    attr_accessor :failure_app
    attr_accessor :default_modules
    attr_accessor :strategies
    attr_accessor :root
    attr_accessor :login_column
    attr_accessor :password_column

    def configure
      yield self
    end

    def model
      @model ||= Module.const_get(classify(@model_name))
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

    def app
      @app ||= Module.const_get(@app_name)
    end
  end

  # Defaults
  @root = Pathname.new File.expand_path(File.dirname(__dir__))
  @logger = ::Logger.new(STDOUT)
  @model_name = "user"
  @app_name = "Auth"
  @failure_app = lambda do |env|
    HanamiId.app::Controllers::Sessions::New.new(
      login_failed_with: env["warden"].message
    ).call(env)
  end
  @default_modules = %w[sessions registrations].freeze
  @strategies = %i[password]
end

I18n.tap do |i18n|
  i18n.load_path << Dir[HanamiId.root.join "locales", "*.yml"]
  i18n.default_locale = :en
  # i18n.enforce_available_locales = false
end
