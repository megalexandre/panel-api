# frozen_string_literal: true

class Bordero < ApplicationRecord
  belongs_to :user
  has_many :receivables
end
