# frozen_string_literal: true

module HanamiId
  module Password
    class << self
      def encrypt(password)
        BCrypt::Password.create(password, cost: 12)
      end
    end
  end
end
