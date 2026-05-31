# frozen_string_literal: true
class ApplicationController < ActionController::API
  before_action :set_paper_trail_whodunnit

  def user_for_paper_trail
    current_user_id if respond_to?(:current_user_id, true)
  end
end
