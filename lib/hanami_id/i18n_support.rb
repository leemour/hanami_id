# frozen_string_literal: true

module HanamiId
  module I18nSupport
    def t(*args)
      I18n.t(*args)
    end
  end
end
