# frozen_string_literal: true

class AutomatedEmailClientConcept < ApplicationRecord
  belongs_to :automated_email
  belongs_to :client_user_concept
end
