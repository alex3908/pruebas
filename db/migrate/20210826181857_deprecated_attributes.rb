# frozen_string_literal: true

class DeprecatedAttributes < ActiveRecord::Migration[5.2]
  def change
    remove_column :clients, :user_id, :integer
    remove_column :documents, :folder_id, :integer
    remove_column :enterprises, :rid, :string
    remove_column :folders, :rid, :string
    remove_column :payment_plans, :rid, :string
    remove_column :phases, :rid, :string
    remove_column :projects, :rid, :string
    remove_column :projects, :logo, :string
    remove_column :referents, :commission, :decimal
    remove_column :structures, :sale_commission, :decimal
    remove_column :structures, :commission, :decimal
    remove_column :structures, :digital, :boolean
    remove_column :users, :rid, :string
    remove_column :stages, :rid, :string
    remove_column :stages, :min_down_payment, :decimal
    remove_column :stages, :first_payment, :integer
    remove_column :stages, :initial_payment, :decimal
    remove_column :stages, :lock_payment, :decimal
    remove_column :stages, :min_capital_payment, :decimal
    remove_column :stages, :min_down_payment_advance, :decimal
    remove_column :stages, :max_grace_months, :integer
    remove_column :stages, :max_delay_payments, :integer
    remove_column :stages, :relative_discount, :boolean
    remove_column :stages, :immediate_extra_months, :integer
    remove_column :stages, :max_percent_immediate_lots_sold, :integer
    remove_column :stages, :max_finance, :integer
    remove_column :stages, :start_installments, :stages, :integer
    drop_table :netpay_services
  end
end
