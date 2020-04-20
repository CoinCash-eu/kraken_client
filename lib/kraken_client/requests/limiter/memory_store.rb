module KrakenClient
  module Requests
    class Limiter
      class MemoryStore < Store
        def initialize
          @count = 0.0
          @timestamp = Time.now
        end

        def get_count
          @count
        end

        def set_count(count)
          @count = count.to_f
        end

        def incr_count(increment)
          @count += increment.to_f
        end

        def get_timestamp
          @timestamp
        end

        def set_timestamp(timestamp)
          @timestamp = timestamp
        end
      end
    end
  end
end
