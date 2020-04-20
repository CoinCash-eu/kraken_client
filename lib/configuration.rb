module KrakenClient
  class Configuration

    attr_accessor :api_key, :api_secret, :base_uri, :api_version,
                  :limiter, :tier, :redis, :limiter_interface

    def initialize
      @api_key             = ENV['KRAKEN_API_KEY']
      @api_secret          = ENV['KRAKEN_API_SECRET']
      @base_uri            = 'https://api.kraken.com'
      @api_version         = 0
      @limiter             = true
      @tier                = 2
      # Define your redis instance for storing the counter
      # to enable ratelimiting across multiple processes
      @redis               = nil

      @limiter_interface ||= KrakenClient::Requests::Limiter.new(self)
    end

  end
end
