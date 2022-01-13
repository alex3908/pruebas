class AddShowFinalPriceToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :show_final_price, :boolean, default: false
    add_column :projects, :show_payment_dates, :boolean, default: true
  end
end
