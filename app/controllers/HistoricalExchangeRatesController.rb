class HistoricalExchangeRatesController < ApplicationController
    def index
      rates = HistoricalExchangeRate.all
  
      # Filtrar por rango de fechas
      if params[:start_date].present? && params[:end_date].present?
        rates = rates.where(date: params[:start_date]..params[:end_date])
      end
  
      # Filtrar por pares de monedas
      if params[:from_currency].present? && params[:to_currency].present?
        rates = rates.where(from_currency: params[:from_currency], to_currency: params[:to_currency])
      end
  
      # Paginación básica
      page = params[:page].to_i > 0 ? params[:page].to_i : 1
      per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 10
      rates = rates.page(page).per(per_page)
  
      render json: rates
    end
  end