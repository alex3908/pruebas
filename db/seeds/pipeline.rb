# frozen_string_literal: true

pipeline_active = Step.create!(name: "Activo", order: 0, folders_expires: true)
pipeline_first = Step.create!(name: "Primer Paso", order: 1)
pipeline_second = Step.create!(name: "Segundo Paso", order: 2)
pipeline_last = Step.create!(name: "Finalizado", order: 3, installments_step: true, lot_status: 2)

step_role_attrs = {
  update_financial: true,
  update_coowners: true,
  can_cancel: true,
  can_approve: true,
  can_soft_reject: true,
  can_reject: true,
  can_comment: true
}

super_admin_role = Role.where(key: "superadmin", is_evo: false).first!
salesman_role = Role.where(key: "salesman", is_evo: true).first!

document_1 = DocumentSection.create!(name: "Sección 1", order: 1)
document_2 = DocumentSection.create!(name: "Sección 2", order: 2)

document_template_1 = DocumentTemplate.create!(name: "Documento 1", document_section: document_1, key: :document_1, order: 1)
document_template_2 = DocumentTemplate.create!(name: "Documento 2", document_section: document_1, key: :document_2, order: 2)
document_template_3 = DocumentTemplate.create!(name: "Documento 3", document_section: document_2, key: :document_3, order: 1)
document_template_4 = DocumentTemplate.create!(name: "Documento 4", document_section: document_2, key: :document_4, order: 2)

StepDocument.find_or_create_by!(step: pipeline_first, document_template: document_template_1).update!(required: true)
StepDocument.find_or_create_by!(step: pipeline_first, document_template: document_template_2).update!(required: true)
StepDocument.find_or_create_by!(step: pipeline_second, document_template: document_template_3).update!(required: true)
StepDocument.find_or_create_by!(step: pipeline_second, document_template: document_template_4).update!(required: true)

step_role_1 = StepRole.create!(step_role_attrs.merge(step: pipeline_active, role: super_admin_role))
step_role_2 = StepRole.create!(step_role_attrs.merge(step: pipeline_first, role: super_admin_role))
step_role_3 = StepRole.create!(step_role_attrs.merge(step: pipeline_second, role: super_admin_role))
step_role_4 = StepRole.create!(step_role_attrs.merge(step: pipeline_last, role: super_admin_role, can_make_installments: true))

step_role_5 = StepRole.create!(step_role_attrs.merge(step: pipeline_active, role: salesman_role))
step_role_6 = StepRole.create!(step_role_attrs.merge(step: pipeline_first, role: salesman_role))
step_role_7 = StepRole.create!(step_role_attrs.merge(step: pipeline_second, role: salesman_role))
step_role_8 = StepRole.create!(step_role_attrs.merge(step: pipeline_last, role: salesman_role, can_make_installments: true))

step_role_doc_template_attrs = {
  readable: true,
  editable: true,
  uploadable: true,
  destroyable: true
}
# DOCUMENTS PERMISSIONS FOR SUPER ADMIN ON ALL 4 STEPS
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_1, document_template: document_template_1).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_1, document_template: document_template_2).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_1, document_template: document_template_3).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_1, document_template: document_template_4).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_2, document_template: document_template_1).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_2, document_template: document_template_2).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_2, document_template: document_template_3).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_2, document_template: document_template_4).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_3, document_template: document_template_1).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_3, document_template: document_template_2).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_3, document_template: document_template_3).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_3, document_template: document_template_4).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_4, document_template: document_template_1).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_4, document_template: document_template_2).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_4, document_template: document_template_3).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_4, document_template: document_template_4).update!(step_role_doc_template_attrs)
# DOCUMENTS PERMISSIONS FOR SALESMAN ON ALL 4 STEPS
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_5, document_template: document_template_1).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_5, document_template: document_template_2).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_5, document_template: document_template_3).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_5, document_template: document_template_4).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_6, document_template: document_template_1).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_6, document_template: document_template_2).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_6, document_template: document_template_3).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_6, document_template: document_template_4).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_7, document_template: document_template_1).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_7, document_template: document_template_2).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_7, document_template: document_template_3).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_7, document_template: document_template_4).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_8, document_template: document_template_1).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_8, document_template: document_template_2).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_8, document_template: document_template_3).update!(step_role_doc_template_attrs)
StepRoleDocumentTemplate.find_or_create_by!(step_role: step_role_8, document_template: document_template_4).update!(step_role_doc_template_attrs)
