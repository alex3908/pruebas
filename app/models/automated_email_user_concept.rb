class AutomatedEmailUserConcept < ApplicationRecord
  belongs_to :automated_email
  belongs_to :folder_user_concept
end
