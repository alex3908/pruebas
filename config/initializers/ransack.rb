# frozen_string_literal: true

Ransack.configure do |c|
  c.add_predicate "end_of_day_lteq",
    arel_predicate: "lteq",
    formatter: proc { |v| v.end_of_day }
end
