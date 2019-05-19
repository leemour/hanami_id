# frozen_string_literal: true

require "hanami/cli/commands"

module HanamiId
  module Generate
    extend Hanami::CLI::Registry

    class Auth < Hanami::CLI::Command
      desc "Generate app with hanami_id integration"

      option :app, default: 'auth', desc: "The application name (default: `auth`)"
      option :model, default: 'user', desc: "The user model name (default: `user`)"

      example [
        "auth # Generate `auth` app"
      ]

      def call(name: 'auth', model: 'user', **)
        HanamiId.logger.info 'Generating Auth app!'
        Hanami::CLI::Commands::Generate::App.new(command_name: 'generate app')
          .call(app: name)
      end
    end

    register "generate auth", Auth
  end
end


Hanami::CLI::Commands.register "generate auth", HanamiId::Generate::Auth
