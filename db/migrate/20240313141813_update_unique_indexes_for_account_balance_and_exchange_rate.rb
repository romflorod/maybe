class UpdateUniqueIndexesForAccountBalanceAndExchangeRate < ActiveRecord::Migration[7.2]
  def change
    if index_name_exists?(:exchange_rates, "index_exchange_rates_on_base_currency_and_converted_currency_and_date")
      rename_index :exchange_rates, "index_exchange_rates_on_base_currency_and_converted_currency_and_date", "index_exchange_rates_on_base_converted_date_unique"
    end
  end
end