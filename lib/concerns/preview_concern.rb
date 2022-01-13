# frozen_string_literal: true

module PreviewConcern
  extend ActiveSupport::Concern
  protected

    def signers
      company_signers = @contract.signers.map do |signer|
        {
          definition: signer.definition.upcase,
          company: signer.company.upcase,
          name: signer.label.upcase,
          role: signer.role.upcase
        }
      end

      folder_signers = [
        {
          definition: "PROMINENTE COMPRADOR",
          name: "JUAN PEREZ GOMEZ",
          company: "EMPRESA INMOBILIARIA SOCIEDAD ANONIMA DE CAPITAL VARIABLE",
          role: "REPRESENTANTE LEGAL"
        },
        {
          definition: "PROMINENTE COMPRADOR",
          name: "JUAN PEREZ GOMEZ",
          company: nil,
          role: nil
        },
        {
          definition: "PROMINENTE COMPRADOR",
          name: "JUAN PEREZ GOMEZ",
          company: nil,
          role: nil
        },
      ]

      company_signers + folder_signers
    end

    # Todo: Deprecate
    def old_attributes
      now = Time.zone.now
      reserve = now - 10.days
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

      {
        "nombre-proyecto" => '<span class="text-uppercase">Proyecto</span>',
        "numero-de-lote" => 600,
        "superficie-de-lote" => 300,
        "mensualidades-totales" => 180,

        "precio-metro-con-numeros" => number_to_currency(2500),
        "precio-metro-con-letras" => number_to_currency_text(2500),
        "precio-metro-con-descuento-con-numeros" => number_to_currency(2500 * 0.90),
        "precio-metro-con-descuento-con-letras" => number_to_currency_text(2500 * 0.90),

        "anticipo-con-numeros" => number_to_currency(5000),
        "anticipo-con-letras" => number_to_currency_text(5000),
        "saldo-enganche-con-numeros" => number_to_currency(52750),
        "saldo-enganche-con-letras" => number_to_currency_text(52750),
        "enganche-con-numeros" => number_to_currency(52750 + 5000),
        "enganche-con-letras" => number_to_currency_text(52750 + 5000),
        "saldo-total-con-numeros" => number_to_currency(577500 - 52750),
        "saldo-total-con-letras" => number_to_currency_text(577500 - 52750),
        "precio-con-letras" => number_to_currency_text(577500),
        "precio-con-numeros" => number_to_currency(577500),

        "fecha-actual" => "<span class='text-uppercase'>#{today}</span>",
        "dia-actual" => "<span class='text-uppercase'>#{currentDay}</span>",
        "mes-actual" => "<span class='text-uppercase'>#{currentMonth}</span>",
        "anio-actual" => "<span class='text-uppercase'>#{currentYear}</span>",

        "fecha-cinco-anios" => "<span class='text-uppercase'>#{nowPlus5YearsText}</span>",
        "fecha-reserva" => "<span class='text-uppercase'>#{reserveDate}</span>",
        "dia-reserva" => "<span class='text-uppercase'>#{reserveDay}</span>",
        "mes-reserva" => "<span class='text-uppercase'>#{reserveMonth}</span>",
        "anio-reserva" => "<span class='text-uppercase'>#{reserveYear}</span>",

        "nombre-fase" => "Etapa",
        "nombre-etapa" => "Privada",
        "prefijo-compuesto-lote" => "Privada"
      }
    end

    def client_old_attributes
      {
        "al-senor" => "al señor",
        "el-senor" => "EL SEÑOR",
        "nombre-completo-cliente" => "JOHN DOE",
        "primer-apellido-cliente" => "Doe",
        "segundo-apellido-cliente" => "Demo",
        "nombres-cliente" => "John",
        "correo-cliente" => "john.doe@correo.com",
        "estado-civil" => "Soltero",
        "ocupacion-cliente" => "Prueba",
        "numero-de-casa" => "99c",
        "calle" => "99",
        "colonia" => "Prueba",
        "codigo-postal" => "99999",
        "localidad" => "Mérida",
        "ciudad" => "Mérida",
        "estado" => "Yucatán",
        "pais" => "México",
        "nacionalidad" => "Mexicano",
        "lugar-de-nacimiento" => "Mérida",
        "fecha-de-nacimiento" => translate_date_by_string("18/12/1991"),
        "tipo-de-identificacion" => "Credencial para votar",
        "institucion-expedidora" => "Instituto Nacional Electoral",
        "numero-de-identificacion" => "Prueba",
        "curp" => "XAXEXX0101010",
        "rfc" => "XEXX010101000",
      }
    end

    def clients
      (0..2).map do
        client_attributes.reverse_merge!(moral_attributes).reverse_merge!(physical_attributes)
      end
    end

    def client_attributes
      {
        "name" => "Juan",
        "primer_apellido" => "Perez",
        "segundo_apellido" => "Gómez",
        "telefono" => "+5219912345678",
        "telefono_secundario" => "+5219912345678",
        "email" => "juan.perez.gomez@example.com",
        "genero" => "Masculino",
        "pronombre_el" => "El señor",
        "pronombre_al" => "al señor",
      }
    end

    def moral_attributes
      {
        "empresa" => {
          "rfc" => "XAXX010101000",
          "nombre" => "Empresa SA de CV",
          "notaria" => "Notaria pública 17",
          "actividad" => "Comercializadora",
          "fecha_de_constitucion" => Time.zone.now - 10.years,
          "identificacion" => {
            "fecha" => Time.zone.now + 2.years,
            "institucion" => "INE",
            "tipo" => "Instituto Nacional Electoral",
            "numero" => "1234567890",
          },
          "notario_publico" => {
            "nombre" => "Notaría Pública",
            "numero" => "908",
            "catalogo_de_la_republica" => "Ciudad de México",
          },
        },
        "representante_legal" => {
          "nombre" => "Juan Pérez Gómez",
          "rfc" => "XAXX010101000",
          "curp" => "MAHJ280603MSPRRV09",
          "fecha_de_nacimiento" => Time.zone.now - 30.years,
          "nacionalidad" => "mexicana",
          "pais_de_nacimiento" => "México",
          "identificacion" => {
            "fecha" => Time.zone.now + 2.years,
            "institucion" => "INE",
            "tipo" => "Instituto Nacional Electoral",
            "numero" => "1234567890",
          },
        },

        "direccion" => {
          "domicilio" => "Paseo de Montejo",
          "numero_exterior" => "10",
          "numero_interior" => "Piso 2",
          "colonia" => "Centro",
          "localidad" => "Centro",
          "ciudad" => "Mérida",
          "estado" => "Yucatán",
          "pais" => "México",
          "codigo_postal" => "97000"
        }
      }
    end

    def physical_attributes
      {
        "rfc" => "XAXX010101000",
        "curp" => "MAHJ280603MSPRRV09",
        "ocupacion" => "Comerciante",
        "estado_civil" => "Casado",
        "regimen_matrimonio" => "Bienes separados",
        "fecha_de_nacimiento" => Time.zone.now - 30.years,
        "nacionalidad" => "mexicana",
        "pais_de_nacimiento" => "México",
        "identificacion" => {
          "fecha" => Time.zone.now + 2.years,
          "institucion" => "INE",
          "tipo" => "Instituto Nacional Electoral",
          "numero" => "1234567890",
        },
        "direccion" => {
          "domicilio" => "Paseo de Montejo",
          "numero_exterior" => "10",
          "numero_interior" => "Piso 2",
          "colonia" => "Centro",
          "localidad" => "Centro",
          "ciudad" => "Mérida",
          "estado" => "Yucatán",
          "pais" => "México",
          "codigo_postal" => "97000"
        }
      }
    end

    def lot_attributes
      {
        "nombre" => "600",
        "area" => "300",
        "nivel_2" => "Privada",
        "nivel_2_fecha" => Time.zone.now - 4.months,
        "nivel_1" => "Etapa",
        "nivel_1_fecha" => Time.zone.now - 2.months,
        "nivel_0" => "Proyecto",
        "folio" => "343",
        "tablaje" => "451451"
      }
    end

    def reserve_attributes
      {
        "fecha_de_reserva" => Time.zone.now - 10.days,
        "folio" => 500,
        "status" => "Revisión",
        "stp_clabe" => "111222333333333334",
      }
    end

    def square_meter_price
      2500 * 0.90
    end

    def entities_attributes
      {
        "primer_nivel" => "Proyecto",
        "segundo_nivel" => "Fase",
        "tercer_nivel" => "Etapa",
        "cuarto_nivel" => "Unidad"
      }
    end

    def payment_attributes
      {
        "metro_cuadrado" => square_meter_price
      }
    end
end
