# frozen_string_literal: true

# When adding a new attribute method in this class you must create its equivalent in the file "preview_concern.rb"
# which is used for the preview of emails and pdfs.
class ClientLiquidHandler < LiquidHandler
  include ContractsHelper, ActionView::Helpers::NumberHelper, ActionView::Helpers::TagHelper
  attr_reader :margin, :contract

  def initialize(client, margin = false)
    @client ||= client
    @strict_variables = false
    super(client)
  end

  def tags_without_value
    template_render(true)
    tags_without_value = []
    @template.errors.each { |error| tags_without_value.push(error.message.gsub("Liquid error: undefined variable", "")) }
    tags_without_value
  end

  protected

    def merged_attributes
      attributes.reverse_merge!(client_old_attributes)
    end

    def template_render(strict_variables)
      @strict_variables = strict_variables
      @template.render(strict_variables ? deep_compact(merged_attributes) : merged_attributes, filters: [LiquidFilters], strict_variables: strict_variables).gsub(">", "><span>").gsub("<", "</span><")
    end

    def deep_compact(hash)
      res_hash = hash.map do |key, value|
        value = deep_compact(value) if value.is_a?(Hash)
        value = deep_array_compact(value) if value.is_a?(Array)
        value = nil if value.blank?
        [key, value]
      end
      res_hash.to_h.compact
    end

    def deep_array_compact(arr)
      new_array = []
      arr.each do |value|
        value = deep_compact(value) if value.is_a?(Hash)
        value = deep_array_compact(value) if value.is_a?(Array)
        value = nil if value.blank?
        new_array << value
      end
      new_array.compact
    end

    def locals
      code_block = template_render(false)
      {
          code_block: code_block
      }
    end


    def attributes
      {
          "cliente" => client
      }
    end

    def client_old_attributes
      add_person_tags(@client)
    end

    def client
      return unless @client.present?

      if @client.person == "moral"
        client_attributes(@client).reverse_merge!(moral_attributes(@client))
      else
        client_attributes(@client).reverse_merge!(physical_attributes(@client))
      end
    end

    def client_attributes(client)
      {
        "name" => tag_present_or_missing(client&.name, "nombre de cliente"),
        "nombre" => tag_present_or_missing(client&.name, "nombre de cliente"),
        "primer_apellido" => tag_present_or_missing(client&.first_surname, "apellido de cliente"),
        "segundo_apellido" => tag_present_or_missing(client&.second_surname, "apellido de cliente"),
        "telefono" => tag_present_or_missing(client.formatted_main_phone, "teléfono de cliente"),
        "telefono_secundario_presente" => client.formatted_optional_phone.present?,
        "telefono_secundario" => tag_present_or_missing(client.formatted_optional_phone, "teléfono secundario del cliente"),
        "email" => tag_present_or_missing(client.email, "correo del cliente"),
        "es_mujer" => (client&.gender == "female"),
        "es_hombre" => (client&.gender == "male"),
        "genero" => tag_present_or_missing(client.get_gender, "género del cliente"),
        "pronombre_el" => client.get_prefix("first_format"),
        "pronombre_al" => client.get_prefix("second_format"),
        "tipo" => tag_present_or_missing(client.get_person_type, "tipo de cliente"),
      }
    end

    def moral_attributes(client)
      {
        "empresa" => {
          "rfc" => tag_present_or_missing(client&.moral_client&.rfc_company, "rfc de cliente"),
          "nombre" => tag_present_or_missing(client&.moral_client&.business_name, "nombre de cliente"),
          "notaria" => tag_present_or_missing(client&.moral_client&.notary_name, "notaria del cliente"),
          "actividad" => tag_present_or_missing(client&.moral_client&.activity, "actividad del cliente"),
          "fecha_de_constitucion" => tag_present_or_missing(client&.moral_client&.constitution_date, "fecha de constitución"),
          "identificacion" => {
            "fecha" => tag_present_or_missing(client&.moral_client&.company_validity_identification, "fecha de validez de identificación de representante legal"),
            "institucion" => tag_present_or_missing(client&.moral_client&.company_identification_type&.institution, "falta tipo de identificacion"),
            "tipo" => tag_present_or_missing(client&.moral_client&.company_identification_type&.display_as, "tipo de identificación de representatne legal"),
            "numero" => tag_present_or_missing(client&.moral_client&.company_identification_number, "número de identificación de representante legal")
          },
          "notario_publico" => {
            "nombre" => tag_present_or_missing(client&.moral_client&.notary_public_name, "nombre del notario público"),
            "numero" => tag_present_or_missing(client&.moral_client&.notary_public_number, "número del notario público"),
            "catalogo_de_la_republica" => tag_present_or_missing(client&.moral_client&.notary_public_catalog_republic, "catálogo de la república del notario público"),
          },
          "numero_de_folio_electronico_mercantil" => tag_present_or_missing(client&.moral_client&.commercial_electronic_folio_number, "número de folio electrónico mercantil"),
          "estado_del_registro_publico" => tag_present_or_missing(client&.moral_client&.public_registry_state, "estado_del_registro_público_de_la_propiedad_y_comercio"),
          "fecha_del_registro_publico" => tag_present_or_missing(client&.moral_client&.public_registry_date, "fecha_del_registro_público_de_la_propiedad_y_comercio"),
        },
        "representante_legal" => {
          "nombre" => tag_present_or_missing(client&.moral_client&.legal_name, "nombre de representante legal"),
          "rfc" => tag_present_or_missing(client&.moral_client&.legal_rfc, "rfc de representante legal"),
          "curp" => tag_present_or_missing(client&.moral_client&.curp, "curp de representante legal"),
          "fecha_de_nacimiento" => tag_present_or_missing(client&.moral_client&.birthdate, "fecha de nacimiento de representante legal"),
          "nacionalidad" => tag_present_or_missing(client&.moral_client&.country_nationality, "nacionalidad de representante legal"),
          "pais_de_nacimiento" => tag_present_or_missing(client&.moral_client&.nationality, "país de nacimiento de representante legal"),
          "identificacion" => {
            "fecha" => tag_present_or_missing(client&.moral_client&.validity_identification, "fecha de validez de identificación de representante legal"),
            "institucion" => tag_present_or_missing(client&.moral_client&.identification_type&.institution, "falta tipo de identificacion"),
            "tipo" => tag_present_or_missing(client&.moral_client&.identification_type&.display_as, "tipo de identificación de representatne legal"),
            "numero" => tag_present_or_missing(client&.moral_client&.identification_number, "número de identificación de representante legal")
          },
        },

        "direccion" => {
          "domicilio" => tag_present_or_missing(client&.moral_client&.street, "domicilio del cliente"),
          "numero_exterior" => tag_present_or_missing(client&.moral_client&.house_number, "número exterior de cliente"),
          "tiene_numero_interior" => client&.moral_client&.interior_number.present?,
          "numero_interior" => tag_present_or_missing(client&.moral_client&.interior_number, "número interior de cliente"),
          "colonia" => tag_present_or_missing(client&.moral_client&.colony, "colonia del cliente"),
          "tiene_localidad" => client&.moral_client&.location.present?,
          "localidad" => tag_present_or_missing(client&.moral_client&.location, "localidad del cliente"),
          "ciudad" => tag_present_or_missing(client&.moral_client&.city, "ciudad del cliente"),
          "estado" => tag_present_or_missing(client&.moral_client&.state, "estado del cliente"),
          "pais" => tag_present_or_missing(client&.moral_client&.country, "país del cliente"),
          "codigo_postal" => tag_present_or_missing(client&.moral_client&.postal_code, "codigo postal del cliente")
        }
      }
    end

    def physical_attributes(client)
      {
        "rfc" => tag_present_or_missing(client&.physical_client&.rfc, "RFC del cliente"),
        "curp" => tag_present_or_missing(client&.physical_client&.curp, "CURP del cliente"),
        "ocupacion" => tag_present_or_missing(client&.physical_client&.occupation, "ocupación del cliente"),
        "estado_civil" => tag_present_or_missing(client&.physical_client&.civil_status, "estado civil del cliente"),
        "regimen_matrimonio" => tag_present_or_missing(client&.physical_client&.regime, "régimen de estado civil del cliente"),
        "fecha_de_nacimiento" => tag_present_or_missing(client&.physical_client&.birthdate, "fecha de nacimiento del cliente"),
        "nacionalidad" => tag_present_or_missing(client&.physical_client&.nationality, "nacionalidad del cliente"),
        "pais_de_nacimiento" => tag_present_or_missing(client&.physical_client&.place_birth, "lugar de nacimiento del cliente"),
        "identificacion" => {
          "fecha" => tag_present_or_missing(client&.physical_client&.validity_identification, "fecha de validez de identificaion del cliente"),
          "institucion" => tag_present_or_missing(client&.physical_client&.identification_type&.institution, "falta tipo de identificacion"),
          "tipo" => tag_present_or_missing(client&.physical_client&.identification_type&.display_as, "tipo de identificación del cliente"),
          "numero" => tag_present_or_missing(client&.physical_client&.identification_number, "número de identificación del cliente"),
        },
        "direccion" => {
          "domicilio" => tag_present_or_missing(client&.physical_client&.street, "calle"),
          "numero_exterior" => tag_present_or_missing(client&.physical_client&.house_number, "número exterior"),
          "tiene_numero_interior" => client&.physical_client&.interior_number.present?,
          "numero_interior" => tag_present_or_missing(client&.physical_client&.interior_number, "número interior"),
          "colonia" => tag_present_or_missing(client&.physical_client&.colony, "colonia"),
          "tiene_localidad" => client&.physical_client&.location.present?,
          "localidad" => tag_present_or_missing(client&.physical_client&.location, "localidad"),
          "ciudad" => tag_present_or_missing(client&.physical_client&.city, "ciudad"),
          "estado" => tag_present_or_missing(client&.physical_client&.state, "estado"),
          "pais" => tag_present_or_missing(client&.physical_client&.country, "país"),
          "codigo_postal" => tag_present_or_missing(client&.physical_client&.postal_code, "código postal")
        }
      }
    end
end
