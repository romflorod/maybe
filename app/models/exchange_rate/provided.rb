module ExchangeRate::Provided
  extend ActiveSupport::Concern

  include Providable

  class_methods do
    def provider_healthy?
      exchange_rates_provider.present? && exchange_rates_provider.healthy?
    end

    private

      def fetch_rates_from_provider(from:, to:, start_date:, end_date: Date.current, cache: false)
        return [] unless exchange_rates_provider.present?

        response = exchange_rates_provider.fetch_exchange_rates \
          from: from,
          to: to,
          start_date: start_date,
          end_date: end_date

        if response.success?
          response.rates.map do |exchange_rate|
            rate = HistoricalExchangeRate.new \
              from_currency: from,
              to_currency: to,
              date: exchange_rate.dig(:date).to_date,
              rate: exchange_rate.dig(:rate)

            rate.save! if cache
            rate
          rescue ActiveRecord::RecordNotUnique
            next
          end
        else
          []
        end
      end

      def fetch_rate_from_provider(from:, to:, date:, cache: false)
        return nil unless exchange_rates_provider.present?

        response = exchange_rates_provider.fetch_exchange_rate \
          from: from,
          to: to,
          date: date

        if response.success?
          rate = ExchangeRate.new \
            from_currency: from,
            to_currency: to,
            rate: response.rate,
            date: date

          if cache
            rate.save! rescue ActiveRecord::RecordNotUnique
          end
          rate
        else
          nil
        end
      end
  end
end
