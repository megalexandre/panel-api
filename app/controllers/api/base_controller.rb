module Api
  class ResourceNotFoundError < StandardError; end
  
  class ValidationError < StandardError
    attr_reader :errors
    def initialize(errors)
      @errors = errors
      super("Validation Failed")
    end
  end

  class BaseController < ActionController::API # Use API se for apenas JSON
    skip_before_action :verify_authenticity_token, raise: false

    rescue_from ResourceNotFoundError, with: :render_resource_not_found
    
    rescue_from ValidationError do |e|
      Rails.logger.error "API Validation Error: #{e.errors.inspect}"
      render json: { errors: e.errors }, status: :unprocessable_entity
    end
    
    protected

    def render_resource_not_found
      render json: { error: "Resource not found" }, status: :not_found
    end

    def render_result(result, resource, serializer_class, status: :ok)
      if result.success?
        render json: serializer_class.new(resource), status: status
      else
        render json: { errors: resource.errors.messages }, status: :unprocessable_entity
      end
    end
  end
end
