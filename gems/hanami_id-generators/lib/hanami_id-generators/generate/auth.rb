# frozen_string_literal: true

require "hanami/cli/commands"

module HanamiId
  module Generate
    extend Hanami::CLI::Registry

    class Auth < Hanami::CLI::Commands::Command
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

      option :name, default: "auth", desc: "Application name"
      option :model, default: "user", desc: "User model name"
      option :modules, type: :array, values: %w[sessions registrations],
        default: %w[sessions registrations], desc: "List of modules"

      example [
        "--app auth --model account --modules registrations"
      ]

      def call(
        name: "auth", model: "user", modules: [], **options
      )
        HanamiId.logger.info "Generating #{name} app!"

        generate_default_app(name)
        generate_default_actions(name, modules)

        context = Hanami::CLI::Commands::Context.new(
          app: name, options: options
        )
        inject_warden_helper(context)
      end

      private

      def generate_default_app(name)
        Hanami::CLI::Commands::Generate::App.new(
          command_name: "generate app"
        ).call(app: name)
      end

      def generate_default_actions(name, modules)
        CONTROLLER_ACTIONS.each do |controller_name, actions|
          actions.each do |action, verb|
            next unless modules.include? controller_name

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

      def inject_warden_helper(context)
        content = "      include HanamiId::Warden::AppHelper"
        destination = project.app_application(context)

        files.inject_line_after_last(destination, /configure do/, content)
        say(:insert, destination)
      end
    end
  end
end

Hanami::CLI::Commands.register "generate auth", HanamiId::Generate::Auth
