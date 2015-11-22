require 'virtus'

##
# Value object for results from getting newest trend
class TrendResult
  include Virtus.model

  attribute :code
  attribute :id
  attribute :data # which is a Hash with category as key and feed object as value

  def to_json
    @data.to_json
  end
end

# Service object to check trend request from API
class GetTrendFromAPI
  def initialize(api_url, form)
    @api_url = api_url
    params = form.attributes.delete_if { |_, value| value.blank? }
    @options = {
      body: params.to_json,
      headers: { 'Content-Type' => 'application/json' }
    }
  end

  def call
    results = HTTParty.post(@api_url, @options)
    trend_results = TrendResult.new(code: results.code, data: results)
    trend_results.id = results.request.last_uri.path.split('/').last
    trend_results
  end
end
