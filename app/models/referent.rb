# frozen_string_literal: true

class Referent < ApplicationRecord
  include Filterable

  belongs_to :referrer, class_name: "User"
  belongs_to :invited, class_name: "User"
end
