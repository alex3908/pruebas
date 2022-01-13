# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NetpaySubscriptions", type: :system do
  before(:all) do
    Capybara.default_max_wait_time = 30
  end

  # Ignore errors about Netpay trackers
  before(:all) do
    RSpec.configure do |config|
      config.after(:each, type: :system, js: true) do
        errors = page.driver.browser.manage.logs.get(:browser)
        if errors.present?
          aggregate_failures "javascript errors" do
            errors.each do |error|
              next if error.message.include?("page_embed_script.js")
              expect(error.level).not_to eq("SEVERE"), error.message
            end
          end
        end
      end
    end
  end

  let(:step_finalized) { Step.find_by!(name: "Finalizado") }
  let(:folder) { Folder.where(step: step_finalized).take }
  let(:netpay_service) { create(:netpay_online_service) }

  describe "subscription form" do
    it "saves relevant ids from netpay on success", js: true do
      subscribe_on_netpay

      subscription = folder.subscription

      expect(page).to have_content("Suscripción activa")
      expect(subscription.subscription_id).to be_truthy
      expect(subscription.online_plan_id).to be_truthy
      expect(subscription.client.online_id).to be_truthy
    end
  end

  describe "subscription webhook" do
    it "creates one cash flow and creates payments on installments based on transaction amount", js: true do
      subscribe_on_netpay

      subscription = folder.subscription
      netpay_sends_transaction_for_initial_payment_and_down_payment(subscription)

      cash_flows = folder.cash_flows
      installments = folder.installments
      expect(cash_flows.count).to eq(1)
      expect(cash_flows.first.amount).to eq(7668.93)
      expect(installments.first.is_paid?).to eq(true)
      expect(installments.second.is_paid?).to eq(true)
    end

    it "completes subscription plans", js: true do
      subscribe_on_netpay

      subscription = folder.subscription
      netpay_sends_transaction_for_initial_payment_and_down_payment(subscription)

      subscription_plans = subscription.subscription_plans
      expect(subscription_plans.first.plan_complete?).to eq(true)
      expect(subscription_plans.second.plan_complete?).to eq(true)
      expect(subscription.active_subscription_plan.concept_description).to eq("financing")
    end

    def fake_netpay_webhook(body = {})
      FakeWebhook.new(
        host: Capybara.current_session.server.host,
        port: Capybara.current_session.server.port,
        headers: {
          content_type: "application/json",
          Authorization: netpay_service.properties["loop_secret_key"]
        },
        path: webhook_subscriptions_path,
        body: { data: body }
      )
    end

    def netpay_sends_transaction_for_initial_payment_and_down_payment(subscription)
      fake_netpay_webhook(
        id: subscription.subscription_id,
        amount: "7668.93",
        object: "Paid",
        transactionTokenId: "57d973cf-96ff-4d1d-94af-4e3a3f3cd9f5"
      ).send
    end
  end

  def subscribe_on_netpay
    netpay_service
    visit new_subscription_path(folder_id: folder.id)
    find('input[placeholder="0000-0000-0000-0000"]').set("4000-0000-0000-0002")
    find('input[placeholder="MM/AA"]').set("08/21")
    find('input[placeholder="CVV"]').set("333")
    find('input[maxlength="200"]').set("aa aa")
    find("button", text: "Pagar").click
  end
end
