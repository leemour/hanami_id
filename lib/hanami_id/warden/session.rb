# frozen_string_literal: true

Warden::Manager.serialize_into_session(&:id)

Warden::Manager.serialize_from_session do |id|
  UserReporsitory.find(id)
end
