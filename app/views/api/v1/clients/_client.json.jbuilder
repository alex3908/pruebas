# frozen_string_literal: true

json.id client.id
json.name client.name
json.first_surname client.first_surname
json.second_surname client.second_surname
json.main_phone client.main_phone
json.optional_phone client.optional_phone
json.email client.email
json.gender client.gender
json.origin client.origin
json.person client.person

additional = client.get_person

if additional.present?
  json.additional do
    if client.person == Client::PHYSICAL
      json.id additional.id
      json.rfc additional.rfc
      json.place_birth additional.place_birth
      json.birthdate additional.birthdate
      json.nationality additional.nationality
      json.civil_status additional.civil_status
      json.regime additional.regime
      json.state additional.state
      json.country additional.country
      json.street additional.street
      json.house_number additional.house_number
      json.colony additional.colony
      json.postal_code additional.postal_code
      json.location additional.location
      json.occupation additional.occupation
      json.city additional.city
      json.identification_number additional.identification_number
      json.curp additional.curp
      json.validity_identification additional.validity_identification
      json.interior_number additional.interior_number

    else
      json.id additional.id
      json.business_name additional.business_name
      json.rfc_company additional.rfc_company
      json.legal_rfc additional.legal_rfc
      json.legal_name additional.legal_name
      json.notary_name additional.notary_name
      json.state additional.state
      json.country additional.country
      json.street additional.street
      json.house_number additional.house_number
      json.colony additional.colony
      json.postal_code additional.postal_code
      json.location additional.location
      json.city additional.city
      json.curp additional.curp
      json.interior_number additional.interior_number
      json.nationality additional.nationality
      json.country_nationality additional.country_nationality
      json.identification_type additional.identification_type.name
      json.company_identification_type additional.company_identification_type.name
      json.identification_number additional.identification_number
      json.validity_identification additional.validity_identification
      json.company_validity_identification additional.company_validity_identification
      json.constitution_date additional.constitution_date
      json.birthdate additional.birthdate
      json.activity additional.activity

    end
  end
end
