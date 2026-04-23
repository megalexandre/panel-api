class Api::ExemploController < Api::BaseController
  include Authenticable

  before_action -> { authorize_role!('admin') }, only: [:admin]

  def user
    render plain: "Olá, #{current_user.email}! Você tem acesso de usuário."
  end

  def admin
    render plain: "Olá, #{current_user.email}! Você tem acesso de administrador."
  end
end
