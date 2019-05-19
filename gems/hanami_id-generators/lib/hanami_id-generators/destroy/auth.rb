# frozen_string_literal: true

require "hanami/cli/commands"

module HanamiId
  module Destroy
    extend Hanami::CLI::Registry

    class Auth < Hanami::CLI::Command
      desc "Destroy app with hanami_id"

      option :app, default: 'auth', desc: "The application name (default: `auth`)"
      option :model, default: 'user', desc: "The user model name (default: `user`)"

      example [
        "auth # Destroy `auth` app"
      ]

      def call(name: 'auth', model: 'user', **)
        HanamiId.logger.info 'Generating Auth app!'
        Hanami::CLI::Commands::Destroy::App.new(command_name: 'destroy app')
          .call(app: name)
      end
    end
  end
end


Hanami::CLI::Commands.register "destroy auth", HanamiId::Destroy::Auth
