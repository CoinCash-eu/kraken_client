require 'kraken_client/requests/limiter/store'
require 'kraken_client/requests/limiter/memory_store'
require 'kraken_client/requests/limiter/redis_store'

module KrakenClient
  module Requests
    class Limiter

      attr_reader :config, :endpoint_name, :store

      def initialize(config)
        @config = config

        @store = if config.redis
          counter_space = if config.api_key
            config.api_key[0..11]
          end

          RedisStore.new config.redis, counter_space
        else
          MemoryStore.new
        end
      end

      def update(endpoint_name)
        return unless config.limiter
        @endpoint_name = endpoint_name

        decrease_counter

        sleep_if_limit_hit
      end

      private

      def sleep_if_limit_hit
        count = store.get_count
        if count >= counter_total
          overflow = count - counter_total
          request_consumption = request_weight * seconds_to_decrement
          wait_time = request_weight + overflow
          sleep wait_time
          update endpoint_name
        else
          store.incr_count request_weight
        end
      end

      def decrease_counter
        now = Time.now
        previous_timestamp = store.get_timestamp
        time_elapsed_in_secs = now - previous_timestamp
        store.set_timestamp now
        decrement = time_elapsed_in_secs / seconds_to_decrement
        result = store.get_count - decrement
        if result < 0
          store.set_count 0
        else
          store.incr_count(-decrement)
        end
      end

      def request_weight
        case endpoint_name
          when 'Ledgers', 'TradesHistory', 'ClosedOrders'
            2
          when 'AddOrder', 'CancelOrder'
            0
          else
            1
        end.to_f
      end

      def counter_total
        @counter_total ||=  begin
          max_call_count = case config.tier
            when :starter then 15
            when :intermediate then 20
            when :pro then 20
          end.to_f
          if config.limiter_call_count_safety_buffer
            [max_call_count - config.limiter_call_count_safety_buffer, 2.0].max
          else
            max_call_count
          end
        end
      end

      def seconds_to_decrement
        @seconds_to_decrement ||=  begin
          seconds_to_call_count_reduction = case config.tier
            when :starter then 3
            when :intermediate then 2
            when :pro then 1
          end.to_f
          if config.limiter_slowdown_ratio
            seconds_to_call_count_reduction * config.limiter_slowdown_ratio
          else
            seconds_to_call_count_reduction
          end
        end
      end
    end
  end
end
