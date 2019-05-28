# rubocop:disable Metrics/ClassLength

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

      option :app, default: "auth", desc: "Application name"
      option :model, default: "user", desc: "User model name"
      option :modules, type: :array, values: HanamiId::MODULES,
        default: HanamiId.default_modules, desc: "List of modules"
      option :id_type, default: "integer", desc: "User model name"
      option :login_column, default: "email", desc: "Login column in the DB"
      option :password_column, default: "password_hash",
        desc: "Password column in the DB"
      option :mode, values: HanamiId::MODES, default: "standalone",
        desc: "Level of itegration in project apps (callbacks, helpers etc.)"

      example [
        "--app auth --model account --modules registrations"
      ]

      attr_accessor :auth_templates
      attr_accessor :context

      def initialize(*args)
        super
        @auth_templates = HanamiId::Generators.templates
      end

      # rubocop:disable Metrics/AbcSize
      def call(
        app:, model:, modules:, login_column:, password_column:, id_type:,
        mode:, **options
      )
        HanamiId.logger.info "Generating #{app} app!"
        HanamiId.model_name = model
        @context = Hanami::CLI::Commands::Context.new(
          app: app,
          model: HanamiId.model_name,
          repository: HanamiId.repository_name,
          modules: modules,
          id_type: id_type,
          login_column: login_column,
          password_column: password_column,
          options: options.merge(project: app)
        )

        generate_default_app
        generate_default_entity
        generate_default_repository
        generate_default_migration
        generate_default_actions(modules)
        generate_default_routes
        add_initializer(mode)
        add_config if mode == "project"
        inject_authentication_require
        inject_warden_helper
      end
      # rubocop:enable Metrics/AbcSize

      private

      def generate_default_app
        Hanami::CLI::Commands::Generate::App.new(
          command_name: "generate app"
        ).call(app: context.app)
      end

      def generate_default_routes
        source = auth_templates.join("routes.erb").to_s
        destination = project.app_routes(context)

        generate_file(source, destination, context)
        say(:create, destination)
      end

      def generate_default_entity
        source = auth_templates.join("entity.erb").to_s
        destination = project.entity(context)

        generate_file(source, destination, context)
        say(:create, destination)
      end

      def generate_default_repository
        source = auth_templates.join("repository.erb").to_s
        destination = project.repository(context)

        generate_file(source, destination, context)
        say(:create, destination)
      end

      def generate_default_migration
        source = auth_templates.join("migration.erb").to_s
        migration_name = Hanami::Utils::Inflector.pluralize HanamiId.model_name
        destination = project.migration(
          context.with(migration: "create_#{migration_name}")
        )

        generate_file(source, destination, context)
        say(:create, destination)
      end

      def generate_default_actions(modules)
        CONTROLLER_ACTIONS.each do |controller_name, actions|
          actions.each do |action, verb|
            next unless modules.include? controller_name

            generate_action(controller_name, action, verb)
          end
        end
      end

      def generate_action(controller_name, action, verb)
        HanamiId.logger.info(
          "Generating #{verb} #{controller_name}##{action}"
        )
        Hanami::CLI::Commands::Generate::Action.new(
          command_name: "generate action"
        ).call(
          app: context.app,
          action: "#{controller_name}##{action}",
          method: verb
        )
        # binding.pry
        # action_code = generate_code(controller_name, action)
        action_code = generate_code("registrations", "create")
        destination = project.action(
          context.with(
            controller: controller_name,
            action: action
          )
        )
        files.inject_line_after(destination, /def call/, action_code)
        say(:insert, destination)
      end

      def add_initializer(mode)
        source = auth_templates.join("config.erb").to_s
        destination = if mode == "project"
          File.join project.initializers, "hanami_id.rb"
        else
          project.root.join(
            "apps", context.app, "config", "hanami_id.rb"
          )
        end
        generate_file(source, destination, context)
        say(:create, destination)
      end

      def add_config
        # TODO: add project-wide integration
        raise "Not implemented"
      end

      def inject_authentication_require
        content = "require \"hanami_id/authentication\""
        destination = project.app_application(context)

        files.inject_line_before(destination, "", content)
        say(:insert, destination)
      end

      def inject_warden_helper
        content = "      include HanamiId::Warden::AppHelper"
        destination = project.app_application(context)

        files.inject_line_after_last(destination, /Application </, content)
        say(:insert, destination)
      end

      def generate_code(controller_name, action)
        template = auth_templates.join(
          "controllers", controller_name, "#{action}.erb"
        )
        render(template.to_s, context)
      end
    end
  end
end

Hanami::CLI::Commands.register "generate auth", HanamiId::Generate::Auth

# rubocop:enable Metrics/ClassLength
