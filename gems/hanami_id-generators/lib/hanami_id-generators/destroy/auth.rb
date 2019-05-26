# frozen_string_literal: true

require "hanami/cli/commands"

module HanamiId
  module Destroy
    extend Hanami::CLI::Registry

    class Auth < Hanami::CLI::Command
      desc "Destroy an app with hanami_id"

      option :name, default: "auth", desc: "Application name"
      option :model, default: "user", desc: "User model name"
      option :modules, type: :array, values: %w[sessions registrations],
        default: %w[sessions registrations], desc: "List of modules"

      example [
        ""
      ]

      def call(
        name: "auth", model: "user", modules: [], **options
      )
        HanamiId.logger.info "Destroying #{name} app!"
        Hanami::CLI::Commands::Destroy::App.new(
          command_name: "destroy app"
        ).call(app: name)

        remove_lib_app_directory
        remove_default_migration
      end

      private

      def remove_lib_app_directory
        destination = project.root.join('lib', name)
        files.delete_directory destination
        say(:remove, destination)
      end

      def remove_default_migration
        raise
      end
    end
  end
end

Hanami::CLI::Commands.register "destroy auth", HanamiId::Destroy::Auth
