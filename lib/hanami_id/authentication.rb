# frozen_string_literal: true

module HanamiId
  module Authentication
    resource = HanamiId.model_name

    attr_reader :"current_#{resource}"

    def self.included(action)
      action.class_eval do
        # before :"authenticate_#{resource}!"
        expose :"current_#{resource}"
      end
    end

    private

    def log_in(resource)
      params.env["warden"].set_user(resource)
    end

    def log_out(resource)
      params.env["warden"].logout
    end

    define_method "authenticate_#{resource}!" do
      send("authenticate_#{resource}")
      halt 401 unless send("#{resource}_signed_in?")
    end

    define_method "authenticate_#{resource}" do
      instance_variable_set(
        "@current_#{resource}",
        params.env["warden"].authenticate!(HanamiId.strategies)
      )
    end

    define_method "#{resource}_signed_in?" do
      !!send("current_#{resource}")
    end
  end
end
