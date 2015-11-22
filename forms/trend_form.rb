require 'virtus'
require 'active_model'

class TrendForm
  include Virtus.model
  include ActiveModel::Validations

  attribute :categories

end
