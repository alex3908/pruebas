# frozen_string_literal: true

# When adding a new attribute method in this class you must create its equivalent in the file "preview_concern.rb"
# which is used for the preview of emails and pdfs.
class PurchasePromise < DocumentHandler
  include QuotationsHelper, ContractsHelper, ActionView::Helpers::NumberHelper, ActionView::Helpers::TagHelper
  attr_reader :margin, :contract

  FILE_PATH = "folders/files/purchase_promise.html.erb"

  def initialize(folder, margin = false)
    @folder ||= folder
    @lot ||= folder.lot
    @quotation ||= folder.generate_quote
    @contract ||= folder.ruled_contract
    @template ||= @contract.template
    @footer ||= @contract&.footer_template
    @margin = margin
    @strict_variables = false
    @two_columns = @contract&.two_columns
    super(FILE_PATH, layout: "pdf")
  end

  def to_pdf(*args)
    args << :with_margin if margin && !args.include?(:with_margin)
    args << :with_page_number if contract.paginated?
    args << :use_grover if @two_columns
    super(*args)
  end

  def for_combine
    CombinePDF.parse to_pdf(:with_page_number, :with_margin)
  end

  def tags_without_value
    template_render(true)
    tags_without_value = []
    @template.errors.each { |error| tags_without_value.push(error.message.gsub("Liquid error: undefined variable", "")) }
    tags_without_value
  end

  protected

    def merged_attributes
      attributes.reverse_merge!(old_attributes).reverse_merge!(client_old_attributes)
    end

    def template_render(strict_variables)
      @strict_variables = strict_variables
      @template.render(strict_variables ? deep_compact(merged_attributes) : merged_attributes, filters: [LiquidFilters], strict_variables: strict_variables).gsub(">", "><span>").gsub("<", "</span><")
    end

    def footer_render(strict_variables)
      return nil if @footer.nil?
      @strict_variables = strict_variables
      @footer.render(strict_variables ? deep_compact(merged_attributes) : merged_attributes, filters: [LiquidFilters], strict_variables: strict_variables).gsub(">", "><span>").gsub("<", "</span><")
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
      footer = footer_render(false)
      {
          code_block: code_block,
          footer: footer,
          two_columns: @two_columns,
      }
    end

    def assigns
      {
          signers: signers
      }
    end

    def signers
      company_signers = @contract.signers.map do |signer|
        {
          definition: signer.definition.upcase,
          company: signer.company.upcase,
          name: signer.label.upcase,
          sign_tag: signer.sign_tag,
          role: signer.role.upcase
        }
      end

      client_definitions = contract_definitions(@contract)
      folder_signers = @folder.clients.map.with_index do |client, index|
        next if client_definitions[index].nil? && client.nil?
        {
          definition: client_definitions[index],
          name: client.label.upcase,
          sign_tag: client.sign_tag,
          company: nil,
          role: nil
        }
      end

      company_signers + folder_signers
    end


    def attributes
      {
          "cliente" => client,
          "clientes" => clients,
          "lote" => lot_attributes,
          "reserva" => reserve_attributes,
          "financiamiento" => payment_attributes,
          "proyecto" => project_attributes
      }
    end

    # Todo: Deprecate
    def old_attributes
      now = Time.zone.now
      reserve = @folder.calc_date
      nowPlus5Years = now + 5.years

      today = "#{now.strftime("%d")} de #{translate_month_by_date(now.strftime("%B"))} de #{now.strftime("%Y")}"
      currentDay = "#{now.strftime("%d")}"
      currentMonth = "#{translate_month_by_date(now.strftime("%B"))}"
      currentYear = "#{now.strftime("%Y")}"

      reserveDate = "#{reserve.strftime("%d")} de #{translate_month_by_date(reserve.strftime("%B"))} de #{reserve.strftime("%Y")}"
      reserveDay = "#{reserve.strftime("%d")}"
      reserveMonth = "#{translate_month_by_date(reserve.strftime("%B"))}"
      reserveYear = "#{reserve.strftime("%Y")}"

      nowPlus5YearsText = "#{nowPlus5Years.strftime("%d")} de #{translate_month_by_date(nowPlus5Years.strftime("%B"))} de #{nowPlus5Years.strftime("%Y")}"

      promo = promotion_calculator(@folder.payment_scheme.buy_price * @lot.area, @folder.payment_scheme.discount, @folder.payment_scheme.promotion_discount, @folder.payment_scheme.promotion_operation, @folder.payment_scheme.promotion&.amount || 0, @folder.payment_scheme.promotion&.operation || nil, @folder.payment_scheme.coupon&.promotion&.amount || 0, @folder.payment_scheme.coupon&.promotion&.operation || nil)
      square_meter_price = promotion_calculator(@folder.payment_scheme.buy_price, @folder.payment_scheme.discount, @folder.payment_scheme.promotion_discount, @folder.payment_scheme.promotion_operation, @folder.payment_scheme.promotion&.amount || 0, @folder.payment_scheme.promotion&.operation || nil, @folder.payment_scheme.coupon&.promotion&.amount || 0, @folder.payment_scheme.coupon&.promotion&.operation || nil)

      {
          "nombre-proyecto" => '<span class="text-uppercase">' + @folder.project.name + "</span>",
          "numero-de-lote" => @folder.lot.name,
          "superficie-de-lote" => @folder.lot.area,
          "mensualidades-totales" => @folder.payment_scheme.total_payments,

          "precio-metro-con-numeros" => number_to_currency(@folder.payment_scheme.buy_price),
          "precio-metro-con-letras" => number_to_currency_text(@folder.payment_scheme.buy_price),
          "precio-metro-con-descuento-con-numeros" => number_to_currency(square_meter_price.total),
          "precio-metro-con-descuento-con-letras" => number_to_currency_text(square_meter_price.total),

          "anticipo-con-numeros" => number_to_currency(@folder.payment_scheme.initial_payment),
          "anticipo-con-letras" => number_to_currency_text(@folder.payment_scheme.initial_payment),
          "saldo-enganche-con-numeros" => number_to_currency(@folder.payment_scheme.down_payment),
          "saldo-enganche-con-letras" => number_to_currency_text(@folder.payment_scheme.down_payment),
          "enganche-con-numeros" => number_to_currency(@folder.payment_scheme.down_payment + @folder.payment_scheme.initial_payment),
          "enganche-con-letras" => number_to_currency_text(@folder.payment_scheme.down_payment + @folder.payment_scheme.initial_payment),
          "saldo-total-con-numeros" => number_to_currency(promo.total - @folder.payment_scheme.down_payment - @folder.payment_scheme.initial_payment),
          "saldo-total-con-letras" => number_to_currency_text(promo.total - @folder.payment_scheme.down_payment - @folder.payment_scheme.initial_payment),
          "precio-con-letras" => number_to_currency_text(promo.total),
          "precio-con-numeros" => number_to_currency(promo.total),

          "fecha-actual" => "<span class='text-uppercase'>#{today}</span>",
          "dia-actual" => "<span class='text-uppercase'>#{currentDay}</span>",
          "mes-actual" => "<span class='text-uppercase'>#{currentMonth}</span>",
          "anio-actual" => "<span class='text-uppercase'>#{currentYear}</span>",

          "fecha-cinco-anios" => "<span class='text-uppercase'>#{nowPlus5YearsText}</span>",
          "fecha-reserva" => "<span class='text-uppercase'>#{reserveDate}</span>",
          "dia-reserva" => "<span class='text-uppercase'>#{reserveDay}</span>",
          "mes-reserva" => "<span class='text-uppercase'>#{reserveMonth}</span>",
          "anio-reserva" => "<span class='text-uppercase'>#{reserveYear}</span>",

          "nombre-fase" => @folder.phase.name,
          "nombre-etapa" => @folder.stage.name,
          "prefijo-compuesto-lote" => mixed_lot_name
      }
    end

    def client_old_attributes
      add_people_tags(@folder)
    end

    def mixed_lot_name
      @folder.phase.name.downcase == @folder.stage.name.downcase ? @folder.stage.name : "#{@folder.phase.name} #{@folder.stage.name}"
    end

    def clients
      @folder.clients.map do |client|
        if client.person == "moral"
          client_attributes(client).reverse_merge!(moral_attributes(client))
        else
          client_attributes(client).reverse_merge!(physical_attributes(client))
        end
      end
    end

    def client
      return unless @folder.client.present?

      if @folder.client.person == "moral"
        client_attributes(@folder.client).reverse_merge!(moral_attributes(@folder.client))
      else
        client_attributes(@folder.client).reverse_merge!(physical_attributes(@folder.client))
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

    def lot_attributes
      {
        "referencia" => @lot.reference,
        "nombre" => @lot.name,
        "area" => @lot.area,
        "nivel_2" => @lot.stage.name,
        "nivel_2_fecha" => @lot.stage.release_date,
        "nivel_1" => @lot.stage.phase.name,
        "nivel_1_fecha" => @lot.stage.phase.start_date,
        "nivel_0" => @lot.stage.phase.project.name,
        "folio" => tag_present_or_missing(@lot.folio, "folio"),
        "tablaje" => tag_present_or_missing(@lot.planking, "tablaje"),
        "proindiviso" => tag_present_or_missing(@lot.undivided, "proindiviso"),
      }
    end

    def reserve_attributes
      {
        "fecha_de_reserva" => @folder.calc_date,
        "stp_clabe" => tag_present_or_missing(@folder.stp_clabe, "configurar sistema STP"),
        "folio" => @folder.id,
        "status" => @folder.step.present? ? @folder.step.name : "Sin paso asignado",
        "esta_cancelado" => @folder.canceled?,
        "esta_expirado" => @folder.expired?,
        "razones_de_rechazo" => reasons_for_rejection(@folder),
        "razon_de_cancelacion" => reasons_for_cancelation(@folder)
      }
    end

    def payment_attributes
      {
        "total" => @quotation.total_with_discount,
        "pagos" => @quotation.payments,
        "enganche" => downpayment_attributes,
        "saldo" => @quotation.total_minus_down_payment,
        "metro_cuadrado" => square_meter_price.total,
        "actualizaciones" => updates_attributes,
        "parcialidades" => installments_attributes
      }
    end

    def project_attributes
      {
        "entidad" => entities_attributes
      }
    end

    def entities_attributes
      {
        "primer_nivel" => @folder.project.project_entity_name,
        "segundo_nivel" => @folder.project.phase_entity_name,
        "tercer_nivel" => @folder.project.stage_entity_name,
        "cuarto_nivel" => @folder.project.lot_entity_name
      }
    end

    def updates_attributes
      @quotation.interest_payments.map do |update|
        {
          "monto" => update[:amount],
          "total_pagos" => update[:payments],
          "interes" => update[:rate]
        }
      end
    end

    def downpayment_attributes
      {
        "total" => @quotation.down_payment,
        "saldo" => @quotation.down_payment - @quotation.initial_payment,
        "anticipo" => @quotation.initial_payment,
        "porcentaje" => @quotation.down_payment_percentage,
        "pagos" => downpayment_installment_attributes
      }
    end

    def downpayment_installment_attributes
      @quotation.down_payment_monthly_payments.map do |payment|
        {
          "pago" => payment[:payment],
          "fecha" => payment[:date],
          "numero" => payment[:number],
        }
      end
    end

    def installments_attributes
      @quotation.amr.map do |payment|
        {
          "pago" => payment[:payment] + payment[:interest],
          "fecha" => payment[:date],
          "numero" => payment[:number],
          "capital" => payment[:capital],
          "interes" => payment[:interest]
        }
      end
    end

    def square_meter_price
      promotion_calculator(@folder.payment_scheme.buy_price, @folder.payment_scheme.discount, @folder.payment_scheme.promotion_discount, @folder.payment_scheme.promotion_operation, @folder.payment_scheme.promotion&.amount || 0, @folder.payment_scheme.promotion&.operation || nil, @folder.payment_scheme.coupon&.promotion&.amount || 0, @folder.payment_scheme.coupon&.promotion&.operation || nil)
    end

    # Todo: Deprecate
    def translate_month_by_date(month)
      months = {
        "January" => "Enero",
        "February" => "Febrero",
        "March" => "Marzo",
        "April" => "Abril",
        "May" => "Mayo",
        "June" => "Junio",
        "July" => "Julio",
        "August" => "Agosto",
        "September" => "Septiembre",
        "October" => "Octubre",
        "November" => "Noviembre",
        "December" => "Diciembre"
      }
      months[month]
    end

    # Todo: Deprecate
    def translate_date_by_string(date)
      date = date.split("/")
      month = date[1]
      months = {
        "01" => "Enero",
        "02" => "Febrero",
        "03" => "Marzo",
        "04" => "Abril",
        "05" => "Mayo",
        "06" => "Junio",
        "07" => "Julio",
        "08" => "Agosto",
        "09" => "Septiembre",
        "10" => "Octubre",
        "11" => "Noviembre",
        "12" => "Diciembre",
      }

      "#{date[0]} de #{months[month]} de #{date[2]}"
    end

    def tag_present_or_missing(tag, error_label)
      if tag.blank?
        return content_tag(:div, "Falta #{error_label}", style: "color: red; display: inline;") unless @strict_variables
      end
      tag
    end

    def reasons_for_rejection(folder)
      evaluation_folders = []
      step_log_query = { status: Folder::STATUS[:ACTIVE], step: folder.step } unless folder.finished?
      last_rejected_evaluation_folder = folder.evaluation_folders.rejected.newest
      if last_rejected_evaluation_folder.present? && (folder.fresh? || folder.under_revision?) && folder.step_logs.where(step_log_query).size > 1
        start_date = last_rejected_evaluation_folder.created_at
        evaluation_folders = folder.evaluation_folders.rejected.where(created_at: (start_date - 15.seconds)..(start_date + 15.seconds))
      end

      evaluation_folders.map do |ev_folder|
        ev_folder.evaluation.question
      end
    end

    def reasons_for_cancelation(folder)
      evaluation_questions = Array.new

      if folder.evaluation_folders.present? && folder.evaluation_folders.canceled.any?
        folder.evaluation_folders.map do |evaluation_folder|
          evaluation_questions << evaluation_folder.evaluation.question
        end
      end

      if folder.canceled_description.present?
        evaluation_questions << folder.canceled_description
      end
    end
end
