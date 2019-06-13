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
          "create" => "POST"
          # "edit"   => "GET",
          # "show"   => "GET",
          # "update" => "PUT",
          # "delete" => "DELETE"
        },
        "passwords" => {
          # "index"  => "GET",
          "new"    => "GET",
          "create" => "POST",
          "edit"   => "GET",
          # "show"   => "GET",
          "update" => "PUT"
          # "delete" => "DELETE"
        },
        "confirmations" => {
          "new" => "GET"
        }
      }.freeze
      TEMPLATES = {
        "sessions"      => %w[
          new
        ],
        "registrations" => %w[
          index
          new
        ],
        "confirmations" => %w[
          new
        ],
        "mailer" => %w[
          confirmation_instructions
          reset_password_instructions
          unlock_instruction
        ],
        "passwords" => %w[
          new
          edit
        ],
        "shared" => %w[
          _links
        ],
        "unlocks" => %w[
          index
          new
        ]
      }.freeze
      VIEWS = {
        "sessions"      => %w[
          _form
          create
          new
        ],
        "registrations" => %w[
          _form
          create
          new
        ],
        "confirmations" => %w[
          _form
          new
        ],
        "passwords"     => %w[
          _edit_form
          _new_form
          create
          new
          update
        ]
      }.freeze

      attr_accessor :auth_templates
      attr_accessor :context

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
        generate_default_views(modules)
        generate_default_templates(modules)
        generate_default_interactors
        generate_default_routes
        generate_initializer(mode)
        generate_config if mode == "project"
        inject_authentication_helpers
        inject_warden_helper
        configure_app
      end
      # rubocop:enable Metrics/AbcSize

      private

      def generate_default_app
        Hanami::CLI::Commands::Generate::App.new(
          command_name: "generate app"
        ).call(app: context.app)
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

      def generate_default_interactors
        source = auth_templates.join(
          "interactors", "registrations", "create.erb"
        ).to_s
        destination = project.root.join(
          "lib", context.app, "interactors", "registrations", "create.rb"
        )

        generate_file(source, destination, context)
        say(:create, destination)
      end

      def generate_default_routes
        source = auth_templates.join("routes.erb").to_s
        destination = project.app_routes(context)

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

      def generate_default_views(modules)
        VIEWS.each do |controller_name, actions|
          actions.each do |action|
            next unless modules.include? controller_name

            generate_view(controller_name, action)
          end
        end
      end

      def generate_default_templates(modules)
        TEMPLATES.each do |controller_name, actions|
          actions.each do |action|
            next unless modules.include? controller_name

            generate_template(controller_name, action)
          end
        end
      end

      # rubocop:disable Metrics/AbcSize
      def generate_action(controller_name, action, verb)
        HanamiId.logger.info(
          "Generating controller #{verb} #{controller_name}##{action}"
        )
        Hanami::CLI::Commands::Generate::Action.new(
          command_name: "generate action"
        ).call(
          app: context.app,
          action: "#{controller_name}##{action}",
          method: verb
        )
        content = generate_code("controllers", controller_name, action)
        destination = project.action(
          context.with(
            controller: controller_name,
            action: action
          )
        )
        files.remove_block(destination, "def call")
        files.inject_line_before(destination, "end", content)
        say(:insert, destination)
      end
      # rubocop:enable Metrics/AbcSize

      def generate_view(controller_name, action)
        HanamiId.logger.info(
          "Generating view #{controller_name}##{action}"
        )
        source = auth_templates.join(
          "views", controller_name, "#{action}.erb"
        )
        destination = project.view(
          context.with(
            controller: controller_name,
            action: action,
            template: "erb"
          )
        )
        generate_file(source, destination, context)
        say(:create, destination)
      end

      def generate_template(controller_name, action)
        HanamiId.logger.info(
          "Generating template #{controller_name}##{action}"
        )
        source = auth_templates.join(
          "templates", controller_name, "#{action}.html.erb"
        )
        destination = project.template(
          context.with(
            controller: controller_name,
            action: action,
            options: {template: "erb"}
          )
        )
        generate_file(source, destination, context)
        say(:create, destination)
      end

      def generate_initializer(mode)
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

      def generate_config
        # TODO: add project-wide integration
        raise "Not implemented"
      end

      def inject_authentication_helpers
        inject_authentication_require
        inject_authentication_include
      end

      def inject_authentication_require
        content = "require \"hanami_id/authentication\""
        destination = project.app_application(context)

        files.inject_line_before(destination, "", content)
        say(:insert, destination)
      end

      def inject_authentication_include
        content = <<-INC
      controller.prepare do
        include HanamiId::Authentication
      end
        INC
        destination = project.app_application(context)

        files.inject_line_after(destination, "configure do", content)
        say(:insert, destination)
      end

      def inject_warden_helper
        content = "    include HanamiId::Warden::AppHelper\n"
        destination = project.app_application(context)

        files.inject_line_after_last(destination, /Application </, content)
        say(:insert, destination)
      end

      def configure_app
        destination = project.app_application(context)
        [
          "cookies max_age: 300",
          "sessions :cookie, secret: " \
            "ENV['#{context.app.upcase}_SESSIONS_SECRET']"
        ].each do |content|
          files.inject_line_before(
            destination, "# #{content}", "      #{content}"
          )
          files.remove_line(destination, "# #{content}")
        end
        say(:insert, destination)
      end

      def generate_code(folder, subfolder, file)
        template = auth_templates.join(
          folder, subfolder, "#{file}.erb"
        )
        render(template.to_s, context)
      end
    end
  end
end

Hanami::CLI::Commands.register "generate auth", HanamiId::Generate::Auth

# rubocop:enable Metrics/ClassLength
