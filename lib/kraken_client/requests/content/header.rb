module KrakenClient
  module Requests
    module Content
      class Header

        attr_accessor :config, :endpoint_name, :options, :url

        def initialize(config, endpoint_name, options, url)
          @config          = config
          @endpoint_name   = endpoint_name
          @url             = url

          @options         = options
          @options[:nonce] = nonce
        end

        def call
          {
            'API-Key' => config.api_key,
            'API-Sign' => generate_signature,
          }
        end

        private

        ## Security

        # Using nanosecond timestamp keeps nonce within the 64-bit range
        # and allows for stable parallel requests using the same API key
        # without getting nonce errors
        def nonce
          (Time.now.to_f * 10e8).to_i.to_s
        end

        def encoded_options
          uri = Addressable::URI.new
          uri.query_hash = options
          uri.query
        end

        def generate_signature
          key = Base64.decode64(config.api_secret)
          message = generate_message
          generate_hmac(key, message)
        end

        def generate_message
          digest = OpenSSL::Digest.new('sha256', options[:nonce] + encoded_options).digest
          url.split('.com').last + digest
        end

        def generate_hmac(key, message)
          Base64.strict_encode64(OpenSSL::HMAC.digest('sha512', key, message))
        end
      end
    end
  end
end
