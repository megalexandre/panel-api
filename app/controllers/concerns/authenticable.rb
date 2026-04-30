module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
    attr_reader :current_user
    helper_method :current_user_id if respond_to?(:helper_method)
  end

  private

  def authenticate_request!
    token = extract_token_from_header
    
    unless token
      return render json: { error: 'Missing authorization token' }, status: :unauthorized
    end

    payload = JwtService.decode(token)

    if payload[:error].present?
      return render json: { error: 'Invalid or expired authorization token' }, status: :unauthorized
    end

    @current_user = User.find_by(id: payload[:user_id])

    unless @current_user
      return render json: { error: 'User not found' }, status: :unauthorized
    end
  end

  def extract_token_from_header
    authorization_header = request.headers['Authorization']
    return nil unless authorization_header

    parts = authorization_header.split(' ')
    return nil unless parts.length == 2 && parts[0] == 'Bearer'

    parts[1]
  end

  def current_user_id
    @current_user&.id
  end

  def authorize_role!(*roles)
    unless (current_user.roles & roles).any?
      render json: { error: 'Insufficient permissions' }, status: :forbidden
    end
  end
end
