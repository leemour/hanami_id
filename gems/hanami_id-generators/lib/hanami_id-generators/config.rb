# frozen_string_literal: true

module HanamiId
  module Generators
    module Config
      CONTROLLER_ACTIONS = {
        "sessions"      => {
          "new"     => "GET",
          "create"  => "POST",
          "destroy" => "DELETE"
        },
        "registrations" => {
          "index"   => "GET",
          "new"     => "GET",
          "create"  => "POST",
          "edit"    => "GET",
          "show"    => "GET",
          "update"  => "PUT",
          "destroy" => "DELETE"
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
    end
  end
end
