# frozen_string_literal: true

class AddQuotationTypeToCreditSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :quotation_type, :string
  end
end
