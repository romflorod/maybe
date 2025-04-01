class HistoricalExchangeRate < ApplicationRecord
    validates :from_currency, :to_currency, :rate, :date, presence: true
    validates :rate, numericality: { greater_than: 0 }
  
    # Add any additional methods or scopes if needed
  end