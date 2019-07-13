# rubocop:disable Metrics/ClassLength
# frozen_string_literal: true

require "hanami/cli/commands"

module HanamiId
  module Generate
    extend Hanami::CLI::Registry

    class Auth < Hanami::CLI::Commands::Command
      include HanamiId::Generators::AppGenerators

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
        },
        "passwords"     => {
          "new"    => "GET",
          "create" => "POST",
          "edit"   => "GET",
          "update" => "PUT"
        },
        "confirmations" => {
          "new"    => "GET",
          "create" => "POST"
        },
        "unlocks"       => {
          "new"    => "GET",
          "create" => "POST"
        }
      }.freeze
      INTERACTORS = {
        "passwords"     => %w[
          update
        ],
        "registrations" => %w[
          create
          update
        ]
      }.freeze
      TEMPLATES = {
        "sessions"      => %w[
          new
        ],
        "registrations" => %w[
          index
          show
          new
          edit
        ],
        "confirmations" => %w[
          new
        ],
        "mailer"        => %w[
          confirmation_instructions
          reset_password_instructions
          unlock_instructions
        ],
        "passwords"     => %w[
          new
          edit
        ],
        "shared"        => %w[
          _links
        ],
        "unlocks"       => %w[
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
          _new_form
          _edit_form
          index
          show
          new
          edit
          create
          update
        ],
        "confirmations" => %w[
          _form
          new
          create
        ],
        "passwords"     => %w[
          _edit_form
          _new_form
          new
          edit
          create
          update
        ],
        "shared"        => %w[
          _links
        ],
        "unlocks"       => %w[
          _form
          new
          create
        ]
      }.freeze

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
      option :mode, values: HanamiId::MODES, default: "standalone",
        desc: "Level of itegration in project apps (callbacks, helpers etc.)"
      option :locale, default: "en", desc: "I18n locale"

      example [
        "--app auth --model account --modules registrations"
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

      # rubocop:disable Metrics/AbcSize
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
        generate_config if context.mode == "project"
        inject_authentication_helpers
        inject_warden_helper
        modify_app_layout
        configure_app
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end

Hanami::CLI::Commands.register "generate auth", HanamiId::Generate::Auth

# rubocop:enable Metrics/ClassLength
