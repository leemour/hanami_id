# frozen_string_literal: true

module HanamiId
  module Authentication
    model = HanamiId.model_name

    attr_reader :"current_#{model}"

    def self.included(action)
      action.class_eval do
        before :"authenticate_#{model}!"
        expose :"current_#{model}"
      end
    end

    private

    define_method "authenticate_#{model}!" do
      instance_variable_set(
        "@current_#{model}",
        HanamiId.repostiory.new.find(session["#{model}_id"])
      )
      halt 401 unless send("#{model}_signed_in?")
    end

    define_method "#{model}_signed_in?" do
      !!send("current_#{model}")
    end
  end
end
