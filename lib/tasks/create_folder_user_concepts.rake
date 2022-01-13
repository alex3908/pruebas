namespace :create_folder_user_concept do
    desc "Static concepts to dinamic concepts relationship"
    task new_concepts: :environment do
        FolderUser.all.each do |folder_user|
            folder_user_concept = FolderUserConcept.find_or_create_by(name:I18n.t("activerecord.attributes.folder_user.concepts.#{folder_user.concept}"))
            folder_user_concept.roles << folder_user.role  if folder_user_concept.roles.where(id:folder_user.role.id).empty?
            folder_user_concept.save
            folder_user.update!(folder_user_concept:folder_user_concept)
        end
    end
end
  