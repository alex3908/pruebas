# frozen_string_literal: true

module ContractsHelper
  def ajax_number_input(contract, contract_annexe)
    number_field_tag(:annexe_amount, contract_annexe.amount,
      min: 0, step: 1, class: "form-control text-right",
        data: {
          remote: true,
          method: :patch,
          url: update_custom_annexe_amount_contract_path(contract: contract.id, contract_annexe_id: contract_annexe.id)
        })
  end

  def number_to_currency_text(money)
    money = money.round(2)
    integer = money.to_i
    decimal = money - integer
    decimal = (decimal.round(2) * 100.0).to_i
    cents_words = decimal < 10 ? "0#{decimal}" : decimal
    price_words = I18n.with_locale(:es) { integer.to_words }

    "#{price_words} pesos #{cents_words}/100 MN"
  end

  def tag_present_or_missing(tag, error_label)
    if tag.nil? || tag == ""
      return "<span style='color:red'>#{error_label}</span>"
    end
    tag
  end

  def add_person(replacements, suffix, client)
    tag_suffix = (suffix == 0) ? "" : "-#{suffix}"

    additional = (client.person == "physical") ? client.physical_client : client.moral_client

    person_replacement = {
      "al-senor#{tag_suffix}" => tag_present_or_missing(client&.get_prefix("first_format"), "cliente"),
      "el-senor#{tag_suffix}" => "<span class='text-uppercase'>#{tag_present_or_missing(client&.get_prefix("second_format"), "cliente") }</span>",
      "nombre-completo-cliente#{tag_suffix}" => "<span class='text-uppercase'>#{client&.label}</span>",
      "primer-apellido-cliente#{tag_suffix}" => tag_present_or_missing(client&.first_surname, "primer apellido del cliente "),
      "segundo-apellido-cliente#{tag_suffix}" => tag_present_or_missing(client&.second_surname, "segundo apellido del cliente"),
      "nombres-cliente#{tag_suffix}" => tag_present_or_missing(client&.name, "nombre/s del cliente"),
      "correo-cliente#{tag_suffix}" => tag_present_or_missing(client&.email, "correo del cliente"),

      "calle#{tag_suffix}" => tag_present_or_missing(additional&.street, "Calle del cliente"),
      "estado#{tag_suffix}" => tag_present_or_missing(additional&.state, "Estado de residencia del cliente"),
      "curp#{tag_suffix}" => tag_present_or_missing(additional&.curp, "CURP del cliente"),
      "numero-de-casa#{tag_suffix}" => tag_present_or_missing(additional&.house_number, "Número de Casa del cliente"),
      "codigo-postal#{tag_suffix}" => tag_present_or_missing(additional&.postal_code, "Código postal del cliente"),
      "localidad#{tag_suffix}" => tag_present_or_missing(additional&.location, "Localidad del cliente"),
      "colonia#{tag_suffix}" => tag_present_or_missing(additional&.colony, "Colonia del cliente"),
      "ciudad#{tag_suffix}" => tag_present_or_missing(additional&.city, "Ciudad de residencia del cliente"),
      "pais#{tag_suffix}" => tag_present_or_missing(additional&.country, "País de residencia del cliente"),

    }

    if client.person == "physical"
      identification_type = tag_present_or_missing(additional&.identification_type&.display_as, "Tipo de Identificación del client")
      expedition_institute = tag_present_or_missing(additional&.identification_type&.institution, "Tipo de Identificación del client")

      person_replacement["estado-civil#{tag_suffix}"] = tag_present_or_missing(additional&.civil_status, "Estado Civil del cliente")
      person_replacement["ocupacion-cliente#{tag_suffix}"] = tag_present_or_missing(additional&.occupation, "Ocupación del Cliente")
      person_replacement["nacionalidad#{tag_suffix}"] = tag_present_or_missing(additional&.nationality, "Nacionalidad del cliente")
      person_replacement["lugar-de-nacimiento#{tag_suffix}"] = tag_present_or_missing(additional&.place_birth, "Lugar de Nacimiento del cliente")
      person_replacement["fecha-de-nacimiento#{tag_suffix}"] = additional&.birthdate.present? ? translate_date_by_string(additional&.birthdate) : tag_present_or_missing(additional&.birthdate, "Fecha de Nacimiento del cliente")
      person_replacement["tipo-de-identificacion#{tag_suffix}"] = identification_type
      person_replacement["institucion-expedidora#{tag_suffix}"] = expedition_institute
      person_replacement["numero-de-identificacion#{tag_suffix}"] = tag_present_or_missing(additional&.identification_number, "Número de Identificación del cliente")
      person_replacement["rfc#{tag_suffix}"] = tag_present_or_missing(additional&.rfc, "RFC del cliente")
    end

    if client.person == "moral"
      person_replacement["rfc-representante-legal#{tag_suffix}"] = tag_present_or_missing(additional&.legal_rfc, "Rfc de representante legal del cliente")
      person_replacement["nombre-representante-legal#{tag_suffix}"] = tag_present_or_missing(additional&.legal_name, "Nombre de representante legal del cliente")
      person_replacement["nombre-notario#{tag_suffix}"] = tag_present_or_missing(additional&.notary_name, "Nombre del notario del cliente")
      person_replacement["rfc#{tag_suffix}"] = tag_present_or_missing(additional&.rfc_company, "RFC de la empresa")
      person_replacement["nombre-empresa#{tag_suffix}"] = tag_present_or_missing(additional&.business_name, "El nombre de la empresa del cliente")
    end

    person_replacement.merge(replacements)
  end

  def add_people_tags(folder)
    replacements = {}
    replacements = add_person(replacements, 0, folder.client)
    replacements = add_person(replacements, 2, folder.client_2) if folder.client_2.present?
    replacements = add_person(replacements, 3, folder.client_3) if folder.client_3.present?
    replacements = add_person(replacements, 4, folder.client_4) if folder.client_4.present?
    replacements = add_person(replacements, 5, folder.client_5) if folder.client_5.present?
    replacements = add_person(replacements, 6, folder.client_6) if folder.client_6.present?
    replacements
  end

  def add_person_tags(client)
    add_person({}, 0, client)
  end

  def contract_definitions(contract)
    definitions = []
    definitions << contract.buyer_definition if contract.buyer_definition.present?
    definitions << contract.coowner_1_definition if contract.coowner_1_definition.present?
    definitions << contract.coowner_2_definition if contract.coowner_2_definition.present?
    definitions << contract.coowner_3_definition if contract.coowner_3_definition.present?
    definitions << contract.coowner_4_definition if contract.coowner_4_definition.present?
    definitions << contract.coowner_5_definition if contract.coowner_5_definition.present?
    definitions
  end
end
