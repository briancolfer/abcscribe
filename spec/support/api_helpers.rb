module ApiHelpers
  def auth_headers(token)
    {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  def json_response
    return nil if response.body.empty?
    JSON.parse(response.body) rescue nil
  end

  def json_request_headers
    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end

