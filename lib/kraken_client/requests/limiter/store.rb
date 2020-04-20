module KrakenClient
  module Requests
    class Limiter
      class Store
        def get_current_count
          raise NotImplementedError
        end

        def set_current_count(count)
          raise NotImplementedError
        end

        def incr_current_count(increment)
          raise NotImplementedError
        end

        def get_timestamp
          raise NotImplementedError
        end

        def set_timestamp(timestamp)
          raise NotImplementedError
        end
      end
    end
  end
end
