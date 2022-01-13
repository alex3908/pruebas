# frozen_string_literal: true

require "paypal-sdk-rest"

class TransactionsController < ApplicationController
  include PayPal::SDK::REST

  def checkout_reserve
    folder = Folder.includes(:lot).find(params[:id])
    stage = Stage.find(folder.stage_id)
    phase = Phase.find(stage.phase_id)
    project = Project.find(phase.project_id)
    initial_payment = "%.2f" % folder.payment_scheme.initial_payment

    @payment = Payment.new(
      intent: "sale",
      payer: {
          payment_method: "paypal" },
      redirect_urls: {
          return_url: "#{request.base_url}/transactions/#{params[:id]}/execute-reserve",
          cancel_url: "#{request.base_url}/transactions/#{params[:id]}/error" },
      transactions: [{
                         item_list: {
                             items: [{
                                         name: "Pago de apartado de la unidad #{folder.lot.name} de la #{phase.name} de la #{stage.name} del desarrollo #{project.name}.",
                                         sku: "#{project.lot_entity_name} #{folder.lot.name}",
                                         price: initial_payment,
                                         currency: "MXN",
                                         quantity: 1 }] },
                         amount: {
                             total: initial_payment,
                             currency: "MXN" },
                         description: "Pago de apartado de la unidad #{folder.lot.name} de la #{phase.name} de la #{stage.name} del desarrollo #{project.name}." }])

    if @payment.create
      @payment.id
      redirect_to @payment.links.find { |v| v.method == "REDIRECT" }.href
    else
      @payment.error
    end
  end

  def checkout_downpayment
    folder = Folder.includes(:lot).find(params[:id])
    stage = Stage.find(folder.stage_id)
    phase = Phase.find(stage.phase_id)
    project = Project.find(phase.project_id)
    down_payment = "%.2f" % (folder.payment_scheme.initial_payment + folder.payment_scheme.down_payment)

    @payment = Payment.new(
      intent: "sale",
      payer: {
          payment_method: "paypal" },
      redirect_urls: {
          return_url: "#{request.base_url}/transactions/#{params[:id]}/execute-downpayment",
          cancel_url: "#{request.base_url}/transactions/#{params[:id]}/error" },
      transactions: [{
                         item_list: {
                             items: [{
                                         name: "Pago de enganche de la unidad #{folder.lot.name} de la #{phase.name} de la #{stage.name} del desarrollo #{project.name}.",
                                         sku: "#{project.lot_entity_name} #{folder.lot.name}",
                                         price: down_payment,
                                         currency: "MXN",
                                         quantity: 1 }] },
                         amount: {
                             total: down_payment,
                             currency: "MXN" },
                         description: "Pago de enganche de la unidad #{folder.lot.name} de la #{phase.name} de la #{stage.name} del desarrollo #{project.name}." }])

    if @payment.create
      @payment.id
      redirect_to @payment.links.find { |v| v.method == "REDIRECT" }.href
    else
      @payment.error
    end
  end

  def execute_reserve
    payment = Payment.find(params["paymentId"])

    if payment.execute(payer_id: params["PayerID"])
      folder = Folder.find(params[:id])
      folder.payment_scheme.online_payment_id = params["paymentId"]
      folder.payment_scheme.save
      redirect_to folder_path(params[:id]), flash: { success: "El pago del anticipo se ha realizado exitosamente" }
    else
      Bugsnag.notify(payment.error)
      redirect_to folder_path(params[:id]), flash: { error: "Se produjo un error al intentar realizar el pago del anticipo" }
    end
  end

  def execute_downpayment
    payment = Payment.find(params["paymentId"])

    if payment.execute(payer_id: params["PayerID"])
      folder = Folder.find(params[:id])
      folder.payment_scheme.online_payment_id = params["paymentId"]
      folder.payment_scheme.down_payment_paid = true
      folder.payment_scheme.save
      redirect_to folder_path(params[:id]), flash: { success: "El pago del enganche se ha realizado exitosamente" }
    else
      Bugsnag.notify(payment.error)
      redirect_to folder_path(params[:id]), flash: { error: "Se produjo un error al intentar realizar el pago del enganche" }
    end
  end

  def error
    redirect_to folder_path(params[:id]), flash: { warning: "Pago cancelado" }
  end
end
