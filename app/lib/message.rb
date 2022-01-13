# frozen_string_literal: true

class Message
  def self.not_found(record = "record")
    "Sorry, #{record} not found."
  end

  def self.invalid_credentials
    "Invalid credentials"
  end

  def self.invalid_token
    "Invalid token"
  end

  def self.invalid_api_key
    "Invalid API Key"
  end

  def self.missing_api_key
    "Missing API Key"
  end

  def self.missing_token
    "Missing token"
  end

  def self.unauthorized
    "Unauthorized request"
  end

  def self.account_created
    "Account created successfully"
  end

  def self.account_not_created
    "Account could not be created"
  end

  def self.bad_request
    "Invalid request data"
  end

  def self.project_stage_not_match
    "The Project does not match with the Project of the Stage"
  end

  def self.stage_lot_not_match
    "The Stage does not match with the Stage of the Lot"
  end

  def self.expired_token
    "Sorry, your token has expired. Please login to continue."
  end
end
