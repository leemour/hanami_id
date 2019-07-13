# frozen_string_literal: true

require "hanami/cli/commands"

module HanamiId
  module Destroy
    extend Hanami::CLI::Registry

    class Auth < Hanami::CLI::Commands::Command
      desc "Destroy an app with hanami_id"

      option :app, default: "auth", desc: "Application name"
      option :model, default: "user", desc: "User model name"
      option :modules, type: :array, values: HanamiId::MODULES,
        default: HanamiId::DEFAULT_MODULES, desc: "List of modules"
      option :mode, values: HanamiId::MODES, default: "standalone",
        desc: "Level of itegration in project apps (callbacks, helpers etc.)"

      example [
        ""
      ]

      def call(app:, model:, mode:, **_options)
        HanamiId.logger.info "Destroying #{app} app!"
        HanamiId.model_name = model
        Hanami::CLI::Commands::Destroy::App.new(
          command_name: "destroy app"
        ).call(app: app)

        remove_lib_app_directory(app)
        remove_default_migration
        update_config
        return unless mode == "project"

        remove_initializer
      end

      private

      def remove_lib_app_directory(app)
        destination = project.root.join("lib", app)
        return unless files.exist?(destination)

        files.delete_directory destination
        say(:remove, destination)
      end

      def remove_default_migration
        migration_name = HanamiId.pluralize HanamiId.model_name
        destination = Dir.glob(
          project.root.join("db", "migrations", "*create_#{migration_name}.rb")
        ).first
        return unless files.exist?(destination)

        files.delete(destination)
        say(:remove, destination)
      end

      def remove_env_vars(app)
        [
          project.root.join(".env.development"),
          project.root.join(".env.test")
        ].each do |path|
          files.remove_line path, /#{app.upcase}_SESSIONS_SECRET/
        end
      end

      def update_config
        # TODO: remove project-wide integration
        destination = project.environment
        content = "    logger level: :debug"

        HanamiId::Generators::AppGenerators::LOGGER_FILTER.each_line do |line|
          files.remove_line(destination, line)
        end
        files.inject_line_after(
          destination, %r{guides/projects/logging}, content
        )
        say(:insert, destination)
      end

      def remove_initializer
        destination = File.join project.initializers, "hanami_id.rb"
        return unless files.exist?(destination)

        files.delete destination
        say(:remove, destination)
      end
    end
  end
end

Hanami::CLI::Commands.register "destroy auth", HanamiId::Destroy::Auth
