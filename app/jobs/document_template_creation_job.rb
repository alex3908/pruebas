# frozen_string_literal: true

class DocumentTemplateCreationJob < ApplicationJob
  queue_as :high_priority

  def perform(document_template)
    if document_template.folder?
      copy_to_all_folders(document_template) if document_template.copy_to_all?
      create_new_step_role_permissions(document_template)
    elsif document_template.client?
      copy_to_all_clients(document_template) if document_template.general?
      copy_to_all_physical_clients(document_template) if document_template.physical?
      copy_to_all_moral_clients(document_template) if document_template.moral?
    end
    create_new_step_requirements(document_template)
  end

  private

    def copy_to_all_clients(document_template)
      Client.all.find_each do |client|
        client.documents.create(document_template: document_template)
      end
    end

    def copy_to_all_physical_clients(document_template)
      Client.where(person: Client::PHYSICAL).find_each do |physical_client|
        physical_client.documents.create(document_template: document_template)
      end
    end

    def copy_to_all_moral_clients(document_template)
      Client.where(person: Client::MORAL).find_each do |moral_client|
        moral_client.documents.create(document_template: document_template)
      end
    end

    def copy_to_all_folders(document_template)
      Folder.find_each do |folder|
        folder.documents.create(document_template: document_template)
      end
    end

    def create_new_step_role_permissions(document_template)
      StepRole.find_each do |step_role|
        StepRoleDocumentTemplate.create(step_role: step_role,
                                        document_template: document_template,
                                        readable: true
                                      )
      end
    end

    def create_new_step_requirements(document_template)
      Step.find_each do |step|
        StepDocument.create(step: step, document_template: document_template)
      end
    end
end
