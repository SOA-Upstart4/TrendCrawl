require 'virtus'
require 'active_model'

##
# Form object
class TrendForm
  include Virtus.model
  include ActiveModel::Validations

  # attribute :description, String
  attribute :categories, Array

  # validates :description, presence: true
  validates :categories, presence: true

  def error_fields
    errors.messages.keys.map(&:to_s).join(', ')
  end
end
