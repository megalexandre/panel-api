module Api
  class ResourceNotFoundError < StandardError; end

  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token, raise: false

    rescue_from ResourceNotFoundError, with: :render_resource_not_found

    protected

    def render_resource_not_found
      render json: { error: "Resource not found" }, status: :not_found
    end

    def render_result(result, resource, serializer_class, status: :ok)
      if result.success?
        render json: serializer_class.new(resource), status: status
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
