module KrakenClient
  module Endpoints
    class Private < Base

      def perform(endpoint_name, args)
        url      = config.base_uri + url_path(endpoint_name)
        response = request_manager.call(url, endpoint_name, args)

        case
        when response.is_a?(Hash)
          response.with_indifferent_access
        when response.is_a?(Array) && response.first.is_a?(Hash)
          response.map(&:with_indifferent_access)
        when response.is_a?(Array) && response.first.is_a?(String) && response.first.match(/^E[\w]+:/)
          fail ErrorResponse.new(response.first)
        when response == "error"
          fail ErrorResponse.new(response)
        else
          response
        end
      end

      def data
        {
          :Balance        => :balance,
          :TradeBalance   => :trade_balance,
          :OpenOrders     => :open_orders,
          :ClosedOrders   => :closed_orders,
          :QueryOrders    => [:query_orders,    params: [:txid]],
          :TradesHistory  => :trades_history,
          :QueryTrades    => [:query_trades,    params: [:txid]],
          :OpenPositions  => :open_positions,   params: [:txid],
          :Ledgers        => :ledgers,
          :QueryLedgers   => [:query_ledgers,   params: [:id]],
          :TradeVolume    => :trade_volume,
          :AddOrder       => [:add_order,       params: [:pair, :type, :ordertype, :volume]],
          :CancelOrder    => [:cancel_order,    params: [:txid]],
          :Withdraw       => [:withdraw,        params: [:asset, :key, :amount]],
          :DepositStatus  => [:deposit_status,  params: [:asset]],
          :WithdrawStatus => [:withdraw_status, params: [:asset]],
        }
      end

      def raise_exception(options, args)
        return unless options.is_a?(Hash)

        leftover = options[:params] - args.keys

        if leftover.length > 0
          fail ::KrakenClient::ArgumentError, "Required options absent. Input must include #{leftover}"
        end
      end

      private

      def url_path(method)
        '/' + config.api_version.to_s + '/private/' + method
      end
    end
  end
end
