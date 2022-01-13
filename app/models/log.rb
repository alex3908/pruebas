# frozen_string_literal: true

class Log < ApplicationRecord
  include Filterable
  belongs_to :user, required: false

  def json_parse
    JSON.parse("#{self.element_changes}")
  end

  def self.contains(column_name, prefix)
    where("lower(#{column_name}) like ?", "%#{prefix.downcase}%")
  end
end
