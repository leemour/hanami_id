# frozen_string_literal: true

Warden::Manager.serialize_into_session(&:id)

Warden::Manager.serialize_from_session do |id|
  Module.const_get("#{HanamiId.model}Repository").new.find(id)
end
