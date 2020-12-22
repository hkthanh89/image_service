require 'aws-sdk-s3'
require 'image_processing/vips'

module ImageService
  class Resizer
    CLIENT = Aws::S3::Client.new region: Env.region
    BUCKET = "image-service-thanh-12122020-#{Env.stage}"

    attr_reader :key, :size

    def initialize(key, size = 200)
      @key = key
      @size = size
    end

    def resize!
      return if resized?
      resized = ImageProcessing::Vips
        .source(source)
        .resize_to_limit(size, nil)
        .call(save: false)
        .write_to_buffer(File.extname(key))
      put_object resized, new_key
    end

    def source
      if File.extname(key) == '.png'
        Vips::Image.pngload_buffer(get_object)
      else
        Vips::Image.new_from_buffer(get_object, File.extname(key))
      end
    end

    def new_key
      "#{File.basename(key, File.extname(key))}-#{size}#{File.extname(key)}"
    end

    def get_object
      CLIENT.get_object(bucket: BUCKET, key: key).body.read
    end

    def put_object(object, put_key)
      CLIENT.put_object bucket: BUCKET, key: put_key, body: object,
                        metadata: { 'resized' => '1' }
    end

    def resized?
      metadata['resized'] == '1'
    end

    def metadata
      response = CLIENT.head_object bucket: BUCKET, key: key
      response.metadata || {}
    rescue Aws::S3::Errors::NotFound
      {}
    end

  end
end