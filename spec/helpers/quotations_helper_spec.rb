# frozen_string_literal: true

require "rails_helper"

# Specs in this file have access to a helper object that includes
# the QuotationsHelper. For example:
#
# describe QuotationsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe QuotationsHelper, type: :helper do
  describe ".generate_amortization" do
    context "simple basic quotation" do
      before(:all) do
        @quotation = generate_amortization(basic_quotation_attributes)
      end

      it "generates basic info" do
        expect(@quotation.plan_name).to eq("160 meses")
        expect(@quotation.total_minus_down_payment.to_f).to be_within(0.0001).of(69020.343)
        expect(@quotation.down_payment_finance).to eq(1)
        expect(@quotation.amount_to_finance).to be_nil
        expect(@quotation.price).to eq(76689.27)
        expect(@quotation.total_price).to eq(76689.27)
        expect(@quotation.initial_payment).to eq(5000)
        expect(@quotation.down_payment).to eq(7668.927)
        expect(@quotation.payments).to eq(160)
        expect(@quotation.complement_payment).to eq(0)
        expect(@quotation.discount).to eq(0)
        expect(@quotation.saving).to eq(0)
        expect(@quotation.is_down_payment_differ).to be false
        expect(@quotation.have_capital_payment).to be false
        expect(@quotation.down_payment_first_pay_date).to eq (Date.today + 8.days).strftime("%d/%m/%Y")
        expect(@quotation.down_payment_percentage).to eq("10.00")
        expect(@quotation.reserve).to be_nil
        expect(@quotation.updates).to be_nil
      end

      it "generates exact values" do
        expect(@quotation.down_payment_to_differ).to eq(7668.927)
        expect(@quotation.total).to eq(76689.27)
        expect(@quotation.total_with_discount).to eq(76689.27)
        expect(@quotation.total_discount).to eq(0.0)
        expect(@quotation.down_payment_total).to eq(7668.927)
        expect(@quotation.down_payment_monthly_payment).to eq(7668.927)
        expect(@quotation.price_with_interest.to_f).to eq(200765.44568638012)
      end

      it "correctly fills amortization table" do
        amr_first_period_payments = @quotation.amr.count { |payment| payment[:payment].round(4) == 431.3771 }
        expect(amr_first_period_payments).to eq(59)

        amr_second_period_payments = @quotation.amr.count { |payment| payment[:payment].round(4) == 687.2646 }
        expect(amr_second_period_payments).to eq(61)

        amr_third_period_payments = @quotation.amr.count { |payment| payment[:payment].round(4) == 720.3424 }
        expect(amr_third_period_payments).to eq(40)
      end

      it "generates approximate interest payments and initial period amounts" do
        interest_payment_amounts = @quotation.interest_payments.map { |p| p[:amount].to_f }
        expect(interest_payment_amounts.first).to be_within(0.0001).of (431.37714375)
        expect(interest_payment_amounts.second).to be_within(0.0001).of (687.2646106143702)
        expect(interest_payment_amounts.third).to be_within(0.0001).of (720.3423855423044)

        initial_period_amounts = @quotation.initial_periods.map { |p| p[:amount].to_f }
        expect(initial_period_amounts.first).to be_within(0.0001).of (431.3771)
        expect(initial_period_amounts.second).to be_within(0.0001).of (687.2646)
        expect(initial_period_amounts.third).to be_within(0.0001).of (720.3423)
      end

      it "generates rates for interest payments and initial periods" do
        interest_payment_rates = @quotation.interest_payments.map { |p| p[:rate] }
        expect(interest_payment_rates.first).to eq(0.0)
        expect(interest_payment_rates.second).to eq(0.01)
        expect(interest_payment_rates.third).to eq(0.0125)

        initial_period_rates = @quotation.initial_periods.map { |p| p[:rate] }
        expect(initial_period_rates.first).to eq(0.0)
        expect(initial_period_rates.second).to eq(0.01)
        expect(initial_period_rates.third).to eq(0.0125)
      end
    end

    def create_simple_scheme
      credit_scheme = CreditScheme.find_or_create_by(id: 1)
      first_period = Period.find_or_create_by(payments: 60, interest: 0, order: 1, credit_scheme: credit_scheme)
      second_period = Period.find_or_create_by(payments: 60, interest: 1, order: 2, credit_scheme: credit_scheme)
      third_period = Period.find_or_create_by(payments: 60, interest: 1.25, order: 3, credit_scheme: credit_scheme)

      [first_period, second_period, third_period]
    end
  end

  def basic_quotation_attributes
    {
      price: 76689.27,
      area: 365.187,
      start_date: Date.today - 1.month,
      date: Date.today,
      total_payments: 160,
      down_payment_total_payments: 1,
      discount: 0,
      buy_price: 210.0,
      initial_payment: 5000.0,
      down_payment: 7668.927,
      first_payment: 8.0,
      zero_rate: nil,
      capital_payments: [],
      promotion: 0.0,
      promotion_operation: "over",
      start_installments: nil,
      zero_rate_extra: 0,
      credit_scheme: create_simple_scheme,
      project_type: "new",
      complement_payment: nil,
      immediate_extra_months: 0
    }
  end
end
