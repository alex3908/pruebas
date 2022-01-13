# frozen_string_literal: true

class QuoteLog < ApplicationRecord
  belongs_to :lot
  belongs_to :client, class_name: "Client"
  belongs_to :user
  belongs_to :folder, required: false

  def self.set_params(params, sort_column, sort_direction)
    order(sort_column + " " + sort_direction).search(params)
  end

  def self.search(params)
    quote_logs = QuoteLog.includes([:client, :user, :folder, lot: [stage: [phase: :project]]])
    quote_logs = quote_logs.where(client_id: Client.where("LOWER(CONCAT(name, first_surname, second_surname)) LIKE LOWER(?)", "%#{params[:name].tr(" ", "%")}%".delete(" \t\r\n"))) if params[:name].present?
    quote_logs = quote_logs.where(client_id: Client.where("LOWER(email) LIKE LOWER(?)", "%#{params[:email]}%".delete(" \t\r\n"))) if params[:email].present?
    quote_logs = quote_logs.where(user_id: User.where("LOWER(CONCAT(first_name,' ',last_name)) LIKE LOWER(?)", "%#{params[:name_seller].tr(" ", "%")}%")) if params[:name_seller].present?
    quote_logs = quote_logs.where(user_id: User.where("LOWER(email) LIKE LOWER(?)", "%#{params[:email_seller]}%".delete(" \t\r\n"))) if params[:email_seller].present?
    quote_logs = quote_logs.where("lots.number" => params[:lot_number].delete(" \t\r\n")) if params[:lot_number].present?
    quote_logs = quote_logs.where("LOWER(lots.label) = LOWER(?)", params[:lot_label]) if params[:lot_label].present?
    quote_logs = quote_logs.where("projects.id" => params[:project]) if params[:project].present?
    quote_logs = quote_logs.where("phases.id" => params[:phase]) if params[:phase].present?
    quote_logs = quote_logs.where("stages.id" => params[:stage]) if params[:stage].present?
    quote_logs = quote_logs.where("folders.id" => params[:folio]) if params[:folio].present?
    quote_logs = quote_logs.where("DATE(quote_logs.creation_date) BETWEEN ? and ?", params[:from_date].to_time.strftime("%Y-%m-%d"), params[:to_date].to_time.strftime("%Y-%m-%d")) if params[:from_date].present? && params[:to_date].present?
    quote_logs
  end
end
