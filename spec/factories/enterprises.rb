# frozen_string_literal: true

FactoryBot.define do
  factory :enterprise do
    business_name { "Empresa Demo" }
    short_business_name { "Empresa Demo" }
    rfc { "XAXX010101000" }
    state { "Yucatan" }
    location { "M\u00E9rida" }
    street { "Calle 29" }
    outdoor_number { "462" }
    indoor_number { "" }
    colony { "Gonzalo Guerrero" }

    factory :enterprise_with_bank_account do
      after(:create) do |enterprise|
        create(:bank_account, payable: enterprise)
      end
    end
  end
end
