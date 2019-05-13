require "hanami_id/version"
require "i18n"

module HanamiId
  class AuthError < StandardError; end

  attr_accessor :model

  def self.configure
    yield self
  end

  def self.repository
    @repository ||= Module.const_get(
      "#{Hanami::Utils::String.classify @model}Repository"
    )
  end
end

I18n.load_path << Dir[File.join File.expand_path("locales"), "*.yml"]
I18n.enforce_available_locales = false
I18n.default_locale = :en
