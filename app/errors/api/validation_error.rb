class Api::ValidationError < StandardError
  attr_reader :errors

  def initialize(errors)
    @errors = errors
    super("Validation Failed")
  end
end