require 'json'
require 'dotenv'
require_relative './image_service/env'
require_relative './image_service/resizer'

def handler(event:, context:)
  key = event['Records'][0].dig('s3','object','key')
  resizer = ImageService::Resizer.new(key, 200)
  resizer.resize!
  { statusCode: 200,
    headers: [{'Content-Type' => 'application/json'}],
    body: JSON.dump({key: key}) }
end
