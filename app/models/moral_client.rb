# frozen_string_literal: true

class MoralClient < ApplicationRecord
  belongs_to :client
  belongs_to :identification_type, required: false
  belongs_to :company_identification_type, class_name: "IdentificationType", required: false

  after_update :binnacle

  def address_label
    "#{street}, Número #{house_number} #{interior_number.present? ? "Interior #{interior_number}" : nil }, Colonia #{colony}, #{postal_code}, #{location}, #{state}, #{country}"
  end

  private

    def binnacle
      unless Current.user.nil?
        filtered_changes = previous_changes
        previous_changes.keys.each do |attr_name, attr_value|
          if previous_changes[attr_name][0].nil?
            filtered_changes = filtered_changes.except(attr_name)
          end
        end
        element_changes = "#{filtered_changes.except(:updated_at, :country)}".gsub("=>", ":")

        if element_changes != "{}"
          @log = {
              date: Time.zone.now,
              element_changes: element_changes,
              element: "client",
              element_id: self.client.id,
              user_id: Current.user.id
          }

          Log.create(@log)
        end
      end
    end
end
