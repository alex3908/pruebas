# frozen_string_literal: true

class WebpayPaymentProcessor < WebpayBaseService
  include PaymentProcessor, GenerateXml

  ENCRYPTION_KEY = Rails.application.secrets.encryption_key
  FIXED_CHAIN = Rails.application.secrets.fixed_chain

  def initialize(fh_vigencia, reference, amount, client, data3ds, test, properties, environment)
    @reference = reference
    @amount = amount
    @client = client
    @data3ds = data3ds
    @fh_vigencia = fh_vigencia
    @test = test
    super(properties, environment)
  end

  def pay
    response = {}

    email = @client.email

    charge_body = {
        reference: @reference,
        amount: @amount,
        moneda: "MXN",
        canal: "W",
        omitir_notif_default: 0,
        promociones: "C",
        st_correo: "1",
        fh_vigencia: @fh_vigencia,
        mail_cliente: email,
        version: "IntegraWPP"
    }

    if @data3ds.present?
      charge_body = charge_body.merge(@data3ds)
    end


    charge_body = {
        business: {
          id_company: Rails.application.secrets.id_company,
          id_branch: Rails.application.secrets.id_branch,
          user: Rails.application.secrets.user,
          pwd: Rails.application.secrets.pwd
        },
        url: charge_body
      }

    xml_body = generate_xml(charge_body)

    aes = AesEncryption.new
    encrypted_xml = aes.encrypt(xml_body, ENCRYPTION_KEY)

    charge_body = {
      xml: "<pgs><data0>#{FIXED_CHAIN}</data0><data>#{encrypted_xml}</data></pgs>"
    }

    charge = RestClient.post(gateway_url("gen"), charge_body, get_headers)
    rescue RestClient::Exception => ex

      if ex.http_code == 400
        response[:error] = "data_invalid"
        response[:message] = "Los datos del cliente son inválidos. Revise la información del cliente y vuelva a intentar."
      elsif ex.http_code == 404
        response[:error] = "not_found"
        response[:message] = "Recurso no encontrado."

      else
        response[:message] = ex.response
        response[:error] = "payment_error"
      end

    rescue StandardError => ex

      response[:error] = "payment_error"
      response[:message] = ex.response

  else

    aes = AesEncryption.new

    data = aes.decrypt(charge, ENCRYPTION_KEY)
    data = Hash.from_xml(data).to_json
    charge = JSON.parse(data).deep_symbolize_keys!

    if charge.dig(:P_RESPONSE, :cd_response) == "success"
      response[:status] = "success"
      response[:formatted_response] = charge
      response[:url] = charge.dig(:P_RESPONSE, :nb_url)
      response[:message] = charge[:nb_response]
    end
    ensure
      return response
    end
end
