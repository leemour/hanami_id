# frozen_string_literal: true

module HanamiId
  module Warden
    module AppHelper
      def self.included(base)
        base.configure do
          middleware.use ::Warden::Manager do |manager|
            manager.default_strategies :password
            manager.failure_app = HanamiId.failure_app
          end
        end
      end
    end

    module ActionHelper
      def self.included(base)
        base.configure do
          use ::Warden::Manager do |manager|
            manager.default_strategies :password
            manager.failure_app = HanamiId.failure_app
          end
        end
      end
    end
  end
end
