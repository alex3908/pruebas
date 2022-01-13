# frozen_string_literal: true

class RemoteService
  attr_accessor :properties
  attr_accessor :mode
  attr_accessor :environment

  FIELD_TYPES = { text: "text", password: "password" }

  def initialize(properties, environment = "test")
    @properties = properties
    @environment = environment
  end

  def environment?(arg)
    arg.to_s == environment
  end

  def valid_service(properties)
    return false if properties.nil?

    properties.each do |key, value|
      return false unless get_fields.include?(key.to_sym) || value.blank?
    end

    true
  end
end
