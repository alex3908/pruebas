# frozen_string_literal: true

namespace :set_pipeline do
  desc "Run set pipeline task"

  task new_orve_structure: :environment do
    active = Step.find_or_create_by(name: "Activo", order: 0, lot_status: 1, folders_expires: true)
    Step.find_or_create_by(name: "Revisión").update(order: 1, lot_status: 1, folders_expires: false)
    Step.find_or_create_by(name: "Tesoreria").update(order: 2, lot_status: 1, folders_expires: false)
    approved = Step.find_or_create_by(name: "Finalizado", order: 3, installments_step: true, lot_status: 2, folders_expires: false)

    Folder.where(status: "active", step_id: nil).each do |folder|
      puts "Folder id #{folder.id} activo, añadiendo pipeline"
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(step: active)
    end

    # All folders with revision status are changed to status active (keeping theis step)
    Folder.where(status: "revision").each do |folder|
      puts "Folder id #{folder.id} bajo revision, moviendo a activo, conservando su paso del pipeline."
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(status: "active")
    end

    # All folders with approved status move to the approved step
    Folder.where(status: "approved").each do |folder|
      puts "Folder id #{folder.id} aprobado, moviendo a activo y añadiendo pipeline"
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(status: "active", step: approved)
    end

    StepLog.where(status: "active").update_all(step_id: active.id)
    StepLog.where(status: "revision").update_all(status: "active")
    StepLog.where(status: "approved").update_all(status: "active", step_id: approved.id)

    super_admin_role = Role.where(key: "superadmin", is_evo: false).first
    StepRole.where(step: active, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true).first_or_create!
    StepRole.where(step: approved, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true, can_make_installments: true).first_or_create!
  end

  task orve: :environment do
    revision = Step.find_or_create_by(name: "Revisión", order: 0)
    tesoreria = Step.find_or_create_by(name: "Tesoreria", order: 1)

    Folder.where(status: %w[revision], step_id: nil).each do |folder|
      puts "Folder id #{folder.id} en revision, añadiendo pipeline"
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(step: revision)
    end
    Folder.where(status: %w[accepted]).each do |folder|
      puts "Folder id #{folder.id} aceptado, moviendo a revision y añadiendo pipeline"
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(step: tesoreria, status: "revision")
    end
    Folder.where(status: %w[rejected]).each do |folder|
      puts "Folder id #{folder.id} rechazado, marcando como activo"
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(status: "active")
    end

    super_admin_role = Role.where(key: "superadmin", is_evo: false).first
    StepRole.where(step: revision, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true).first_or_create!
    StepRole.where(step: tesoreria, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true).first_or_create!
  end

  task new_rosavento_structure: :environment do
    active = Step.find_or_create_by(name: "Activo", order: 0, lot_status: 1, folders_expires: true)
    Step.find_or_create_by(name: "Validación Digital").update(order: 1, lot_status: 1, folders_expires: false)
    Step.find_or_create_by(name: "Solicitud de Envío").update(order: 2, lot_status: 1, folders_expires: false)
    Step.find_or_create_by(name: "Validación Física").update(order: 3, lot_status: 1, folders_expires: false)
    Step.find_or_create_by(name: "Pago de Comisión").update(order: 4, lot_status: 1, folders_expires: false)
    Step.find_or_create_by(name: "Envío a Cliente").update(order: 5, lot_status: 1, folders_expires: false)
    Step.find_or_create_by(name: "Firma de RL").update(order: 6, lot_status: 1, folders_expires: false)
    approved = Step.find_or_create_by(name: "Finalizado", order: 7, installments_step: true, lot_status: 2, folders_expires: false)

    Folder.where(status: "active", step_id: nil).each do |folder|
      puts "Folder id #{folder.id} activo, añadiendo pipeline"
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(step: active)
    end

    # All folders with revision status are changed to status active (keeping theis step)
    Folder.where(status: "revision").each do |folder|
      puts "Folder id #{folder.id} bajo revision, moviendo a activo, conservando su paso del pipeline."
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(status: "active")
    end

    # All folders with approved status move to the approved step
    Folder.where(status: "approved").each do |folder|
      puts "Folder id #{folder.id} aprobado, moviendo a activo y añadiendo pipeline"
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(status: "active", step: approved)
    end

    StepLog.where(status: "active").update_all(step_id: active.id)
    StepLog.where(status: "revision").update_all(status: "active")
    StepLog.where(status: "approved").update_all(status: "active", step_id: approved.id)

    super_admin_role = Role.where(key: "superadmin", is_evo: false).first
    StepRole.where(step: active, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true).first_or_create!
    StepRole.where(step: approved, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true, can_make_installments: true).first_or_create!
  end

  task rosavento: :environment do
    digital = Step.find_or_create_by(name: "Validación Digital", order: 0)
    envio = Step.find_or_create_by(name: "Solicitud de Envío", order: 1)
    fisica = Step.find_or_create_by(name: "Validación Física", order: 2, reject_step: envio)
    comision = Step.find_or_create_by(name: "Pago de Comisión", order: 3, reject_step: envio)
    cliente = Step.find_or_create_by(name: "Envío a Cliente", order: 4)
    firma_rl = Step.find_or_create_by(name: "Firma de RL", order: 5)

    Folder.where(status: %w[revision], step_id: nil).each do |folder|
      puts "Folder id #{folder.id} en revision, añadiendo pipeline"
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(step: digital)
    end
    Folder.where(status: %w[accepted]).each do |folder|
      puts "Folder id #{folder.id} aceptado, moviendo a revision y añadiendo pipeline"
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(step: fisica, status: "revision")
    end
    Folder.where(status: %w[rejected]).each do |folder|
      puts "Folder id #{folder.id} rechazado, marcando como activo"
      Bugsang.notify("Expediente #{folder.id} no pudo se asignado a un pipeline") unless folder.update(status: "active")
    end

    super_admin_role = Role.where(key: "superadmin", is_evo: false).first
    StepRole.where(step: digital, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true).first_or_create!
    StepRole.where(step: envio, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true).first_or_create!
    StepRole.where(step: fisica, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true).first_or_create!
    StepRole.where(step: comision, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true).first_or_create!
    StepRole.where(step: cliente, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true).first_or_create!
    StepRole.where(step: firma_rl, role: super_admin_role, update_financial: true, update_coowners: true, can_cancel: true, can_approve: true, can_soft_reject: true, can_reject: true).first_or_create!
  end
end
