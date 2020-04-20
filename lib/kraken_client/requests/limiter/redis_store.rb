module KrakenClient
  module Requests
    class Limiter
      class RedisStore < Store
        attr_accessor :redis, :redis_key

        def initialize(redis, api_key)
          @redis = redis
          @redis_key = "ratelimiter:kraken:#{api_key}"
        end

        def get_count
          redis.hget(redis_key, :count).to_f
        end

        def set_count(count)
          redis.hset(redis_key, :count, count.to_f)
        end

        def incr_count(increment)
          redis.hincrbyfloat(redis_key, :count, increment.to_f)
        end

        def get_timestamp
          raw_timestamp = redis.hget(redis_key, :timestamp)
          if raw_timestamp.nil?
            now = Time.now
            set_timestamp now
            now
          else
            Time.at(raw_timestamp.to_f)
          end
        end

        def set_timestamp(timestamp)
          redis.hset(redis_key, :timestamp, timestamp.to_f)
        end
      end
    end
  end
end
