class CreateHistoricalExchangeRates < ActiveRecord::Migration[7.2]
  def change
    create_table :historical_exchange_rates, id: :uuid do |t|
      t.string :from_currency, null: false
      t.string :to_currency, null: false
      t.decimal :rate, null: false
      t.date :date, null: false

      t.timestamps
    end

    add_index :historical_exchange_rates, %i[from_currency to_currency date], unique: true
  end
end