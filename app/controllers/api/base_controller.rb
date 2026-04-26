module Api
  class ResourceNotFoundError < StandardError; end

  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token, raise: false

    rescue_from ResourceNotFoundError, with: :render_resource_not_found

    protected

    def render_resource_not_found
      render json: { error: "Resource not found" }, status: :not_found
    end

    def render_resource(resource, serializer_class, status: :ok, message: nil, key: :data)
      serializer = serializer_class.new(resource)
      payload = {}
      payload[key] = serializer
      payload[:message] = message if message.present?

      render json: payload, status: status
    end
  end
end
