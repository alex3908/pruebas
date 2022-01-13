# frozen_string_literal: true

namespace :set_opening_comission_to_credit_scheme do
  task run: :environment do
    Stage.all.each do |stage|
      if !stage.opening_commission.blank? && stage.credit_scheme.present?
        stage.credit_scheme.update_columns(is_opening_commission: true, opening_commission: stage.opening_commission)
      end
    end
  end
end
