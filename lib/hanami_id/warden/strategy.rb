# frozen_string_literal: true

Warden::Strategies.add(:password) do
  def valid?
    params[:login] || params[:password]
  end

  def authenticate!
    user = HanamiId.repository.authenticate(params[:login], params[:password])
    user.nil? ? fail!(I18n.t("errors.authentication_failed")) : success!(user)
  end
end
