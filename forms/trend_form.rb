require 'virtus'
require 'active_model'

##
# String attribute for form objects of TutorialForm
class StringStripped < Virtus::Attribute
  def coerce(value)
    value.is_a?(String) ? value.strip : nil
  end
end

##
# Array<String> attribute for form objects of TutorialForm
class ArrayOfNames < Virtus::Attribute
  def coerce(value)
    value.is_a?(String) ?
      value.split("\r\n").map(&:strip).reject(&:empty?) : nil
  end
end

##
# Form object
class TutorialForm
  include Virtus.model
  include ActiveModel::Validations

  attribute :categories, ArrayOfNames

  def error_fields
    errors.messages.keys.map(&:to_s).join(', ')
  end
end
