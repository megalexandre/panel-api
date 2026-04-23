class Api::AuthController < Api::BaseController
  def login
    service = AuthService.new(email: params[:email], password: params[:password])
    user    = service.authenticate

    if user
      tokens = AuthService.issue_tokens(user)
      render json: AuthSerializer.new(tokens).login_response, status: :ok
    else
      render json: { errors: service.errors }, status: :unauthorized
    end
  end

  def refresh
    return render json: { error: 'Missing refresh token' }, status: :unauthorized unless params[:refresh_token].present?

    result = AuthService.refresh(params[:refresh_token])

    if result[:error]
      render json: { error: result[:error] }, status: :unauthorized
    else
      render json: result, status: :ok
    end
  end
end