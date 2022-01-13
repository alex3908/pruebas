namespace :automated_email do
  desc "Run create_automated_email_user_concepts task"

  task create_user_concepts: :environment do
    AutomatedEmail.where.not(folder_user_concept_id: nil).each do |automated_email|
      AutomatedEmailUserConcept.create(automated_email_id: automated_email.id, folder_user_concept_id: automated_email.folder_user_concept_id)
    end
  end

  task assign_type: :environment do
    AutomatedEmail.where(automated_type: nil).update_all(automated_type: "folders")
  end
end
