class FetchExchangeRatesJob < ApplicationJob
  queue_as :default

  def perform
    # Define las monedas y el rango de fechas
    currencies = %w[USD EUR GBP JPY] # Ajusta las monedas según tus necesidades
    start_date = Date.yesterday
    end_date = Date.current

    currencies.combination(2).each do |from, to|
      begin
        # Llama al método para obtener los tipos de cambio
        rates = ExchangeRate.fetch_rates_from_provider(
          from: from,
          to: to,
          start_date: start_date,
          end_date: end_date,
          cache: false
        )

        # Guarda los tipos de cambio en HistoricalExchangeRate
        rates.each do |rate_data|
          historical_rate = HistoricalExchangeRate.new(
            from_currency: rate_data.from_currency,
            to_currency: rate_data.to_currency,
            rate: rate_data.rate,
            date: rate_data.date
          )

          if historical_rate.valid?
            historical_rate.save!
          else
            Rails.logger.error("Invalid rate data: #{historical_rate.errors.full_messages.join(', ')}")
          end
        end
      rescue StandardError => e
        Rails.logger.error("Error fetching rates for #{from} to #{to}: #{e.message}")
      end
    end
  end
end