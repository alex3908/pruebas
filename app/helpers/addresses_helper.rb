# frozen_string_literal: true

module AddressesHelper
  def state_options_(address)
    options = [["Selecciona un estado", nil]]
    options << [address.state] if address&.state.present?
    options << ["Otros", "custom"]
    options
  end

  def city_options_(address)
    options = [["Selecciona una ciudad", nil]]
    options << [address.city] if address&.city.present?
    options << ["Otros", "custom"]
    options
  end

  def colony_options_(address)
    options = [["Selecciona una colonia", nil]]
    options << [address.colony] if address&.colony.present?
    options << ["Otros", "custom"]
    options
  end
end
