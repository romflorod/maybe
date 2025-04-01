# filepath: d:\pt\maybe\db\migrate\20240706151026_rename_rate_fields.rb
class RenameRateFields < ActiveRecord::Migration[7.2]
  def change
    if column_exists?(:exchange_rates, :base_currency)
      rename_column :exchange_rates, :base_currency, :from_currency
    end

    if column_exists?(:exchange_rates, :converted_currency)
      rename_column :exchange_rates, :converted_currency, :to_currency
    end
  end
end