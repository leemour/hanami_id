# frozen_string_literal: true

Warden::Strategies.add(:password) do
  def valid?
    params[:login] || params[:password]
  end

  def authenticate!
    resource = HanamiId.repository.authenticate(
      params[:login],
      params[:password]
    )
    resource ? success!(resource) : nil
  end
end
