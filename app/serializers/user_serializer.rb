# frozen_string_literal: true
class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      id:    @user.id,
      email: @user.email,
      roles: @user.roles
    }
  end
end
