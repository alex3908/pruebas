# frozen_string_literal: true

if @can_reserve && @client.present?
  json.client do
    json.name @client.label
    json.email @client.email
    json.phone @client.formatted_main_phone
    if @client.optional_phone.present?
      json.optional_phone @client.formatted_optional_phone
    end
  end
end
json.quotation do
  json.project_singular @project_singular
  json.phase_singular @project.phase_entity_name
  json.phase_name @phase.name
  json.stage_singular @project.stage_entity_name
  json.stage_name @stage.name
  json.lot @lot.name
  json.area text_to_decimal(@lot.area, 6)
  json.interest_free_period @quotation.interest_free_period
  json.total_payments @folder.nil? ? @total_payments : @folder.payment_scheme.total_payments
  json.chepina @lot.chepina.attached? ? URI.join(ActionController::Base.asset_host, rails_blob_path(@lot.chepina)) : ""


  if @quotation.present?
    json.discounts do
      json.applicable_discount text_to_decimal(@quotation.discount, 6)
      json.list_price text_to_decimal(@quotation.price, 6)
      json.saving text_to_decimal(@quotation.saving, 6)
      json.final_price text_to_decimal(@quotation.total_price, 6)
    end
  end
  json.down_payment do
    json.amount text_to_decimal(@down_payment_amount, 6)
    json.percentage text_to_decimal(@quotation.down_payment_percentage, 6)
    json.initial_payment text_to_decimal(@initial_payment, 6)
    json.to_differ text_to_decimal(@quotation.down_payment_to_differ, 6)
    json.first_payment (@folder.nil? ? @stage.credit_scheme.first_payment : @folder.payment_scheme.first_payment)
  end
  json.payments do
    if @quotation.present?
      json.updates do
        json.array! @quotation.interest_payments do |payment|
          json.update payment[:interest]
          json.amount text_to_decimal(payment[:amount], 6)
          json.payments payment[:payments]
        end
      end
      json.down_payments do
        json.array! @quotation.down_payment_monthly_payments do |payment|
            json.number payment[:number]
            json.date payment[:date].strftime("%d/%m/%Y")
            json.total text_to_decimal(payment[:payment], 6)
          end
      end
      json.amortizations do
        json.monthly_payments do
            json.array! @quotation.amr do |payment|
                json.payment_number payment[:number]
                json.date payment[:date].strftime("%d/%m/%Y")
                json.capital text_to_decimal(payment[:capital], 6)
                json.update text_to_decimal(payment[:interest], 6)

                if @quotation.is_down_payment_differ
                  json.down_payment number_to_currency(payment[:down_payment])
                end

                json.payment text_to_decimal(payment[:payment], 6)

                if @quotation.have_capital_payment
                  json.capital_payment text_to_decimal(payment[:capital_payment], 6)
                end

                json.amount text_to_decimal(payment[:amount], 6)
              end
          end
        json.totals do
          json.capital_total text_to_decimal(@capital_total, 6)
          json.interest_total text_to_decimal(@interest_total, 6)
          if @quotation.is_down_payment_differ
            json.down_payment_total text_to_decimal(@down_payment_total, 6)
          end
          json.payment_total text_to_decimal(@payment_total, 6)
          if @quotation.have_capital_payment
            json.capital_payments_total text_to_decimal(@capital_payments_total, 6)
          end
        end
      end
    end
  end


  json.discounts do
    json.array! @relative_plans do |plan|
      json.lower_limit plan[1].first.total_payments
      json.upper_limit plan[1].last.total_payments
      json.discount_percentaje plan.first.to_f
    end
  end


  if @simple_quotations.present? && @simple_quotations.count > 1
    json.simple_quotations do
      json.array! @simple_quotations do |quotation|
          json.payment_number (quotation[:payments] == 1 ? "Contado" : "#{quotation[:payments]} meses")
          json.amortization_1 text_to_decimal(quotation[:updates].first[:amount], 6) if quotation[:updates].first && quotation[:updates].first[:payments] > 0
          if @project.quotation != "conventional"
            json.amortization_2 text_to_decimal(quotation[:updates].second[:amount], 6) if quotation[:updates].second && quotation[:updates].second[:payments] > 0
            json.amortization_3 text_to_decimal(quotation[:updates].third[:amount], 6) if quotation[:updates].third && quotation[:updates].third[:payments] > 0
          end
          json.lot_price text_to_decimal(quotation[:price], 6)
        end
    end
  end

  json.invalid_rules do
    json.array! @invalid_rules
  end
end
