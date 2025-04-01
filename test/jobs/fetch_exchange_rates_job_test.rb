require "test_helper"

class FetchExchangeRatesJobTest < ActiveJob::TestCase
  test "should fetch and save exchange rates" do
    # Configura datos de prueba
    from_currency = "USD"
    to_currency = "EUR"
    start_date = Date.yesterday
    end_date = Date.current

    # Simula la respuesta del proveedor de tipos de cambio
    mock_rates = [
      OpenStruct.new(from_currency: from_currency, to_currency: to_currency, rate: 0.85, date: start_date),
      OpenStruct.new(from_currency: from_currency, to_currency: to_currency, rate: 0.86, date: end_date)
    ]

    ExchangeRate.stub :fetch_rates_from_provider, mock_rates do
      assert_difference "HistoricalExchangeRate.count", 2 do
        FetchExchangeRatesJob.perform_now
      end
    end

    # Verifica que los datos se hayan guardado correctamente
    saved_rates = HistoricalExchangeRate.where(from_currency: from_currency, to_currency: to_currency)
    assert_equal 2, saved_rates.count
    assert_equal 0.85, saved_rates.find_by(date: start_date).rate
    assert_equal 0.86, saved_rates.find_by(date: end_date).rate
  end

  test "should handle errors gracefully" do
    # Simula un error en el proveedor de tipos de cambio
    ExchangeRate.stub :fetch_rates_from_provider, -> { raise StandardError, "Test error" } do
      assert_nothing_raised do
        FetchExchangeRatesJob.perform_now
      end
    end
  end
end