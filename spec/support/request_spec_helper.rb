module RequestSpecHelper
  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelper, type: :request
end

