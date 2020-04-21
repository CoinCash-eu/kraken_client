module KrakenClient
  class Configuration

    attr_accessor :api_key, :api_secret, :base_uri, :api_version,
                  :limiter, :tier, :limiter_call_count_safety_buffer,
                  :limiter_slowdown_ratio, :redis, :limiter_interface

    def initialize
      @api_key                          = nil
      @api_secret                       = nil
      @base_uri                         = 'https://api.kraken.com'
      @api_version                      = 0

      # Ratelimiter settings
      @limiter                          = true
      @tier                             = :starter # :intermediate, :pro
      # Start limiting before we would hit max call counts
      @limiter_call_count_safety_buffer = 4
      # Decreasing call counter slower than documented
      @limiter_slowdown_ratio           = 1.4
      # Define your redis instance for storing the counter
      # to enable ratelimiting across multiple processes
      @redis                            = nil

      @limiter_interface ||= KrakenClient::Requests::Limiter.new(self)
    end

  end
end
