# frozen_string_literal: true

require "hanami/cli/commands"

module HanamiId
  module Generate
    extend Hanami::CLI::Registry

    class Auth < Hanami::CLI::Command
      CONTROLLER_ACTIONS = {
        "sessions"      => {
          "new"    => "GET",
          "create" => "POST",
          "delete" => "DELETE"
        },
        "registrations" => {
          "index"  => "GET",
          "new"    => "GET",
          "create" => "POST",
          "edit"   => "GET",
          "show"   => "GET",
          "update" => "PUT",
          "delete" => "DELETE"
        }
      }.freeze

      desc "Generate app with hanami_id integration"

      option :app, default: "auth", desc: "Application name (default: `auth`)"
      option :model, default: "user", desc: "User model name (default: `user`)"

      example [
        "auth # Generate `auth` app"
      ]

      def call(name: "auth", model: "user")
        HanamiId.logger.info "Generating Auth app!"
        Hanami::CLI::Commands::Generate::App.new(command_name: "generate app")
          .call(app: name)

        CONTROLLER_ACTIONS.each do |controller_name, actions|
          actions.each do |action, verb|
            HanamiId.logger.info(
              "Generating #{verb} #{controller_name}##{action}"
            )
            Hanami::CLI::Commands::Generate::Action.new(
              command_name: "generate action"
            ).call(
              app: name, action: "#{controller_name}##{action}", method: verb
            )
          end
        end
      end
    end
  end
end

Hanami::CLI::Commands.register "generate auth", HanamiId::Generate::Auth
