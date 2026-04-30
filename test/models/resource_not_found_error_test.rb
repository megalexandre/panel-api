# frozen_string_literal: true
require 'test_helper'

class ResourceNotFoundErrorTest < ActiveSupport::TestCase
  test 'ResourceNotFoundError can be raised and rescued' do
    assert_raises(ResourceNotFoundError) do
      raise ResourceNotFoundError, 'not found'
    end
  end
end
