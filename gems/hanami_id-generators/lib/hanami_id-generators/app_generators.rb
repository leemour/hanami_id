# frozen_string_literal: true

module HanamiId
  module Generators
    module AppGenerators
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
        migration_name = HanamiId.pluralize HanamiId.model_name
        destination = project.migration(
          context.with(migration: "create_#{migration_name}")
        )

        generate_file(source, destination, context)
        say(:create, destination)
      end

      def generate_default_interactors
        self.class::INTERACTORS.each do |controller_name, actions|
          next if unused_modules.include? controller_name

          actions.each do |action|
            source = auth_templates.join(
              "interactors", controller_name, "#{action}.erb"
            ).to_s
            destination = project.root.join(
              "lib", context.app, "interactors", controller_name, "#{action}.rb"
            )

            generate_file(source, destination, context)
            say(:create, destination)
          end
        end
      end

      def generate_default_routes
        source = auth_templates.join("routes.erb").to_s
        destination = project.app_routes(context)

        generate_file(source, destination, context)
        say(:create, destination)
      end

      def generate_default_actions
        self.class::CONTROLLER_ACTIONS.each do |controller_name, actions|
          next if unused_modules.include? controller_name

          actions.each do |action, verb|
            generate_action(controller_name, action, verb)
          end
        end
      end

      def generate_default_views
        self.class::VIEWS.each do |controller_name, actions|
          next if unused_modules.include? controller_name

          actions.each do |action|
            generate_view(controller_name, action)
          end
        end
      end

      def generate_default_templates
        self.class::TEMPLATES.each do |controller_name, actions|
          next if unused_modules.include? controller_name

          actions.each do |action|
            generate_template(controller_name, action)
          end
        end
      end

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

      def generate_initializer
        source = auth_templates.join("config.erb").to_s
        destination = if context.mode == "project"
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
        include HanamiId::I18nSupport
      end
      view.prepare do
        include HanamiId::I18nSupport
      end
      I18n.locale = :#{context.locale}
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

      def modify_app_layout
        content = "    <title><%= local :title %><title>"
        destination = project.app_template(context)

        files.replace_first_line(destination, /<title>/, content)
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
