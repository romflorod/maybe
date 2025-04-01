class ExchangeRatesController < ApplicationController
  def index
    @from_currency = params[:from_currency]
    @to_currency = params[:to_currency]
    @start_date = params[:start_date] || Date.today.beginning_of_month
    @end_date = params[:end_date] || Date.today

    if @from_currency.present? && @to_currency.present?
      @exchange_rates = ExchangeRate.find_rates(
        from: @from_currency,
        to: @to_currency,
        start_date: @start_date,
        end_date: @end_date
      )
    else
      @exchange_rates = []
    end
  end
end