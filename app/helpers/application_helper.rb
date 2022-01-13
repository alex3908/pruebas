# frozen_string_literal: true

module ApplicationHelper
  def wicked_blob_path(image)
    return unless image.respond_to?(:blob)
    save_path = Rails.root.join("tmp", "#{image.id}")
    File.open(save_path, "wb") do |file|
      file << image.blob.download
    end
    save_path.to_s
  end

  def current_path?(test_path)
    "active" if request.path.starts_with? test_path
  end

  def active_class(link_path)
    # request.path.starts_with?(link_path) ? " active" : ""
    # " active" if request.path.starts_with?(link_path)
    " active" if request.path == link_path
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    sorted_column = sort_column

    # Rename the sorted column when the column is from other model
    sorted_column == "users.first_name" ? sorted_column = "user_id" : sorted_column
    sorted_column == "discounts.name" ? sorted_column = "discount_id" : sorted_column
    sorted_column == "clients.name" ? sorted_column = "client_id" : sorted_column
    sorted_column == "lots.name" ? sorted_column = "lot_id" : sorted_column
    sorted_column == "projects.name" ? sorted_column = "project_id" : sorted_column
    sorted_column == "phases.name" ? sorted_column = "phase_id" : sorted_column
    sorted_column == "stages.name" ? sorted_column = "stage_id" : sorted_column
    sorted_column == "branches.name" ? sorted_column = "branch_id" : sorted_column
    sorted_column == "payments.number" ? sorted_column = "payment_id" : sorted_column
    sorted_column == "roles.name" ? sorted_column = "role_id" : sorted_column
    sorted_column == "signers.name" ? sorted_column = "signer_id" : sorted_column
    sorted_column == "folders.id" ? sorted_column = "folio" : sorted_column
    sorted_column == "folders.created_at" ? sorted_column = "folder_created" : sorted_column
    sorted_column == "commissions.created_at" ? sorted_column = "commission_created" : sorted_column
    sorted_column == "client_users.created_at" ? sorted_column = "client_user_created" : sorted_column

    css_class = (column == sorted_column) ? "current #{sort_direction}" : nil
    direction = (column == sorted_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, params.to_enum.to_h.merge(sort: column, direction: direction), class: css_class
  end

  def pluralize_without_count(count, singular, plural)
    if count != 0
      count == 1 ? "#{singular}" : "#{plural}"
    end
  end

  def translate_month_name(month)
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

  def is_evo_active?
    @evo_active
  end

  def import_excel(file)
    initial_row = 2
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    import_array = Array.new

    (initial_row..spreadsheet.last_row).each do |i|
      import_array.push(Hash[[header, spreadsheet.row(i)].transpose])
    end

    import_array
  end

  def will_paginate_renderer
    Class.new(WillPaginate::ActionView::LinkRenderer) do
      def container_attributes
        { class: "" }
      end
    end
  end

  def help_tooltip(title)
    tag.i(class: "fa fa-info-circle fa-folder-size", title: title, "aria-hidden": true, rel: "tooltip")
  end
end
