# frozen_string_literal: true

require "hanami/cli/commands"

module HanamiId
  module Generate
    extend Hanami::CLI::Registry

    class Auth < Hanami::CLI::Commands::Command
      include HanamiId::Generators::AppGenerators
      include HanamiId::Generators::Config

      attr_accessor :auth_templates
      attr_accessor :context
      attr_accessor :unused_modules

      desc "Generate app with hanami_id integration"

      option :app, default: "auth", desc: "Application name"
      option :model, default: "user", desc: "User model name"
      option :modules, type: :array,
        default: HanamiId::DEFAULT_MODULES, desc: "List of modules"
      option :id_type, default: "integer", desc: "User model name"
      option :login_column, default: "email", desc: "Login column in the DB"
      option :password_column, default: "password_hash",
        desc: "Password column in the DB"
      option :mode, values: HanamiId::MODES, default: "project",
        desc: "Level of itegration in project apps (callbacks, helpers etc.)"
      option :locale, default: "en", desc: "I18n locale"

      example [
        "--app auth --model account --modules=sessions,registrations"
      ]

      def initialize(*args)
        super
        @auth_templates = HanamiId::Generators.templates
      end

      def call(
        app:, model:, modules:, login_column:, password_column:, id_type:,
        mode:, locale:, **options
      )
        HanamiId.logger.info "Generating #{app} app!"
        HanamiId.model_name = model
        modules = HanamiId::MODULES if modules == "all"
        @unused_modules = HanamiId::MODULES - modules
        @context = Hanami::CLI::Commands::Context.new(
          app: app,
          model: HanamiId.model_name,
          repository: HanamiId.repository_name,
          modules: modules,
          mode: mode,
          id_type: id_type,
          login_column: login_column,
          password_column: password_column,
          options: options.merge(project: app),
          locale: locale,
          template: "erb"
        )

        run_generators
      end

      private

      def run_generators
        generate_default_app
        generate_default_entity
        generate_default_repository
        generate_default_migration
        generate_default_actions
        generate_default_views
        generate_default_templates
        generate_default_interactors
        generate_default_routes
        generate_initializer
        update_project_config
        inject_dependencies
        modify_app_layout
        configure_app
      end
    end
  end
end

Hanami::CLI::Commands.register "generate auth", HanamiId::Generate::Auth
