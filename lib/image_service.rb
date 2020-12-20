require 'json'
require 'dotenv'
# Add your gem requires here:
# require 'some_gem'
require_relative './image_service/env'
# Add your additional lib PORO requires here:
# require_relative './image_service/some_poro

def handler(event:, context:)
  puts event
  { statusCode: 200,
    headers: [{'Content-Type' => 'application/json'}],
    body: JSON.dump(event) }
end
