# frozen_string_literal: true

require "aws-sdk-s3"

module Snappier
  module AwsS3
    class Persistence
      def initialize(region:, bucket_name:, credentials: nil)
        @client = if credentials
                    Aws::S3::Client.new(region: region, credentials: credentials)
                  else
                    Aws::S3::Client.new(region: region)
                  end
        @bucket = Aws::S3::Resource.new(client: @client).bucket(bucket_name)
      end

      def persist(type:, id:, at:, args:)
        path = File.join("snappier", type, id, "#{at}.yml")
        @bucket.object(path).put(body: args.to_yaml)
      end

      def each(type:, id:)
        dir_path = File.join("snappier", type.to_s, id)
        keys = @bucket.objects(prefix: dir_path).map { |object| object.data.key }.sort
        keys.each { |key| yield entry(key) }
      end

      def entry(key)
        milliseconds = File.basename(key).split(".").first
        {
          at: Time.at(milliseconds.to_i / 1000),
          content: YAML.load(@bucket.object(key).get.body.read)
        }
      end
    end
  end
end
