# frozen_string_literal: true

::Warden::Strategies.add(:password) do
  def valid?
    params.key? "session"
  end

  def authenticate!
    session = params["session"]
    resource = HanamiId.repository.new.authenticate(
      session["login"],
      session["password"]
    )
    resource ? success!(resource) : nil
  end
end
