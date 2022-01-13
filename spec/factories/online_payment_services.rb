# frozen_string_literal: true

FactoryBot.define do
  factory :online_payment_service do
    factory :netpay_online_service do
      provider { :netpay }
      enterprise { Enterprise.first }
      properties {
        {
          "charge_public_key" => "pk_netpay_zPNEgtqalPiKnlYcjhBoZUihv",
          "charge_secret_key" => "sk_netpay_lyUUHORZlTDZHxbVAASSdXeCyxSOtuuSIcaDscGQhixMH",
          "loop_public_key" => "pk_netpay_TspojaWplnGFwEPlbqunGLEak",
          "loop_secret_key" => "sk_netpay_mmbPcZUDQoQCtvMMELXGLQnwjgkKVRteIvKvkmtSAdksp"
        }
      }
      environment { "test" }
    end
  end
end
