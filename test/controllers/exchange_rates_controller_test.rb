require "test_helper"

class ExchangeRatesControllerTest < ActionDispatch::IntegrationTest
  test "should route to exchange_rates#index" do
    assert_routing "/exchange_rates", controller: "exchange_rates", action: "index"
  end

  test "should route to historical_exchange_rates#index" do
    assert_routing "/historical_exchange_rates", controller: "historical_exchange_rates", action: "index"
  end
end

class ExchangeRatesControllerTest < ActionDispatch::IntegrationTest
  test "should get index without parameters" do
    get exchange_rates_url
    assert_response :success
    assert_select "p", text: "No exchange rates found for the selected criteria."
  end

  test "should get index with valid parameters" do
    # Crea datos de prueba
    ExchangeRate.create!(from_currency: "USD", to_currency: "EUR", rate: 0.85, date: Date.today)

    get exchange_rates_url, params: { from_currency: "USD", to_currency: "EUR", start_date: Date.today, end_date: Date.today }
    assert_response :success
    assert_select "td", text: "0.85"
  end

  test "should get index with missing parameters" do
    get exchange_rates_url, params: { from_currency: "USD" }
    assert_response :success
    assert_select "p", text: "No exchange rates found for the selected criteria."
  end

  test "should get index with no results" do
    get exchange_rates_url, params: { from_currency: "USD", to_currency: "EUR", start_date: "2025-01-01", end_date: "2025-01-31" }
    assert_response :success
    assert_select "p", text: "No exchange rates found for the selected criteria."
  end
end