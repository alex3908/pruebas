# frozen_string_literal: true

Permission.find_by(subject_class: "Role", action: "create").update(description: "Permite acceder al formulario para crear roles.")
Permission.find_by(subject_class: "Role", action: "read").update(description: "Permite acceder a la lista de roles.")
Permission.find_by(subject_class: "Role", action: "update").update(description: "Permite editar los roles existentes.")
Permission.find_by(subject_class: "Role", action: "permission_to").update(description: "Permite manipular los permisos asignados a un rol.")

Permission.find_by(subject_class: "Project", action: "create").update(description: "Permite acceder al formulario para crear desarrollos.")
Permission.find_by(subject_class: "Project", action: "read").update(description: "Permite acceder a la lista de desarrollos.")
Permission.find_by(subject_class: "Project", action: "update").update(description: "Permite editar los desarrollos existentes.")

Permission.find_by(subject_class: "User", action: "create").update(description: "Permite acceder al formulario para crear usuarios.")
Permission.find_by(subject_class: "User", action: "read").update(description: "Permite acceder a la lista de usuarios.")
Permission.find_by(subject_class: "User", action: "update").update(description: "Permite editar los usuarios existentes.")
Permission.find_by(subject_class: "User", action: "assignment").update(description: "Permite asignar desarrollos y privadas a los usuarios con permiso de creación de reservas.")
Permission.find_by(subject_class: "User", action: "change_password").update(description: "Permite manipular la contraseña desde el formulario de usuarios.")
Permission.find_by(subject_class: "User", action: "activate_user").update(description: "Permite cambiar el estado de una cuenta.")
Permission.find_by(subject_class: "User", action: "report").update(description: "Permite la descarga del reporte de usuarios.")
Permission.find_by(subject_class: "User", action: "become").update(description: "Permite ingresar a la cuenta de los usuario.")
Permission.find_by(subject_class: "User", action: "see_binnacle").update(description: "Permite visualizar la bitácora en usuarios y EVO.")
Permission.find_by(subject_class: "User", action: "see_sellers").update(description: "Limita la vista de usuarios para unicamente ver a los usuarios con permiso de reserva.")

Permission.find_by(subject_class: "Stage", action: "create").update(description: "Permite acceder al formulario para crear privadas.")
Permission.find_by(subject_class: "Stage", action: "read").update(description: "Permite acceder a la lista de privadas. *Necesita acceso a las etapas")
Permission.find_by(subject_class: "Stage", action: "update").update(description: "Permite editar las privadas existentes.")
Permission.find_by(subject_class: "Stage", action: "status").update(description: "Permite activar o desactivar privadas.")

Permission.find_by(subject_class: "Phase", action: "create").update(description: "Permite acceder al formulario para crear etapas.")
Permission.find_by(subject_class: "Phase", action: "read").update(description: "Permite acceder a la lista de etapas. *Necesita acceso a los desarrollos")
Permission.find_by(subject_class: "Phase", action: "update").update(description: "Permite editar las etapas existentes.")

Permission.find_by(subject_class: "Lot", action: "create").update(description: "Permite acceder al formulario para crear lotes.")
Permission.find_by(subject_class: "Lot", action: "read").update(description: "Permite acceder a la lista de lotes. *Necesita acceso a las privadas")
Permission.find_by(subject_class: "Lot", action: "update").update(description: "Permite editar los lotes existentes.")
Permission.find_by(subject_class: "Lot", action: "destroy").update(description: "Permite eliminar lotes existentes sin reservas.")
Permission.find_by(subject_class: "Lot", action: "lock").update(description: "Permite bloquear la reserva de un lote.")

Permission.find_by(subject_class: "Client", action: "create").update(description: "Permite acceder al formulario para crear clientes.")
Permission.find_by(subject_class: "Client", action: "read").update(description: "Permite acceder a la lista de clientes.")
Permission.find_by(subject_class: "Client", action: "update").update(description: "Permite editar los clientes existentes.")
Permission.find_by(subject_class: "Client", action: "see_binnacle").update(description: "Permite visualizar la bitácora de clientes.")
Permission.find_by(subject_class: "Client", action: "rename").update(description: "Permite renombrar clientes.")

Permission.find_by(subject_class: "BankAccount", action: "create").update(description: "Permite acceder al formulario para crear cuentas bancarias.")
Permission.find_by(subject_class: "BankAccount", action: "read").update(description: "Permite acceder a la lista de cuentas bancarias. *Necesita acceso a las empresas")
Permission.find_by(subject_class: "BankAccount", action: "update").update(description: "Permite editar las cuentas bancarias existentes.")

Permission.find_by(subject_class: "Enterprise", action: "create").update(description: "Permite acceder al formulario para crear empresas.")
Permission.find_by(subject_class: "Enterprise", action: "read").update(description: "Permite acceder a la lista de empresas.")
Permission.find_by(subject_class: "Enterprise", action: "update").update(description: "Permite editar las empresas existentes.")

Permission.find_by(subject_class: "Branch", action: "create").update(description: "Permite acceder al formulario para crear sucursales.")
Permission.find_by(subject_class: "Branch", action: "read").update(description: "Permite acceder a la lista de sucursales.")
Permission.find_by(subject_class: "Branch", action: "update").update(description: "Permite editar las sucursales existentes.")

Permission.find_by(subject_class: "Folder", action: "read").update(description: "Permite acceder a la lista de expedientes.")
Permission.find_by(subject_class: "Folder", action: "change_buyer").update(description: "Permite activar la copropiedad en un expediente.")
Permission.find_by(subject_class: "Folder", action: "see_all").update(description: "Permite el acceso a todos los expedientes creados.")
Permission.find_by(subject_class: "Folder", action: "report").update(description: "Permite la descarga del reporte de expedientes.")
Permission.find_by(subject_class: "Folder", action: "purchase_promise").update(description: "Permite descargar el pdf con la promesa de compraventa.")
Permission.find_by(subject_class: "Folder", action: "see_binnacle").update(description: "Permite visualizar la bitácora de expedientes.")
Permission.find_by(subject_class: "Folder", action: "download_templates").update(description: "Permite descargar las plantillas del desarrollo desde un expediente.")
Permission.find_by(subject_class: "Folder", action: "reactivate").update(description: "Permite reactivar los expedientes expirados.")

Permission.find_by(subject_class: "Contract", action: "create").update(description: "Permite acceder al formulario para crear contratos.")
Permission.find_by(subject_class: "Contract", action: "read").update(description: "Permite acceder a la lista de contratos. *Necesita acceso a los desarrollos")
Permission.find_by(subject_class: "Contract", action: "update").update(description: "Permite editar los contratos existentes.")
Permission.find_by(subject_class: "Contract", action: "see_binnacle").update(description: "Permite visualizar la bitácora de contratos.")

Permission.find_by(subject_class: ":quote", action: "quote").update(description: "Permite a los usuarios generar cotizaciones.")
Permission.find_by(subject_class: ":quote", action: "reserve").update(description: "Permite a los usuarios generar las reservas sobre una cotización. Es necesario activar el permiso de Cotizar.")

Permission.find_by(subject_class: "CashFlow", action: "read").update(description: "Permite acceder al historial de pagos. *Necesita acceso a cobranza")

Permission.find_by(subject_class: "PaymentMethod", action: "create").update(description: "Permite acceder al formulario para crear métodos de pago.")
Permission.find_by(subject_class: "PaymentMethod", action: "read").update(description: "Permite acceder a la lista de métodos de pago.")
Permission.find_by(subject_class: "PaymentMethod", action: "update").update(description: "Permite editar los métodos de pago existentes.")

Permission.find_by(subject_class: "Commission", action: "read").update(description: "Permite acceder a la lista de comisiones.")
Permission.find_by(subject_class: "Commission", action: "update").update(description: "Permite editar las comisiones existentes.")

Permission.find_by(subject_class: "Structure", action: "read").update(description: "Permite acceder a la lista de niveles.")
Permission.find_by(subject_class: "Structure", action: "destroy").update(description: "Permite eliminar niveles existentes sin subordinados.")
Permission.find_by(subject_class: "Structure", action: "hire_and_fire").update(description: "Permite asignar o retirar a los responsables de los niveles.")
Permission.find_by(subject_class: "Structure", action: "approval").update(description: "Permite aprobar o rechazar niveles de ventas.")
Permission.find_by(subject_class: "Structure", action: "affiliated_user").update(description: "Permite la afiliación de un usuario existente a un nuevo nivel.")
Permission.find_by(subject_class: "Structure", action: "create_user").update(description: "Permite la creación de un nuevo usuario en un nivel.")
Permission.find_by(subject_class: "Structure", action: "set_level_to_role").update(description: "Permite la configuración del rol que tendrá un nodo en el multinivel.")

Permission.find_by(subject_class: "Installment", action: "set_date").update(description: "Permite al usuario personalizar la fecha de los pagos.")
Permission.find_by(subject_class: "Installment", action: "create").update(description: "Permite crear pagos a los expedientes. *Necesita acceso a la vista de cobranza")
Permission.find_by(subject_class: "Installment", action: "account_status").update(description: "Permite la descarga del pdf con el estado de cuenta.")

Permission.find_by(subject_class: "Setting", action: "read").update(description: "Permite acceder a la lista de configuraciones.")
Permission.find_by(subject_class: "Setting", action: "update").update(description: "Permite editar las configuraciones existentes.")

Permission.find_by(subject_class: "Promotion", action: "read").update(description: "Permite acceder a la lista de promociones.")
Permission.find_by(subject_class: "Promotion", action: "create").update(description: "Permite acceder al formulario para crear promociones.")
Permission.find_by(subject_class: "Promotion", action: "update").update(description: "Permite editar las promociones existentes.")
Permission.find_by(subject_class: "Promotion", action: "destroy").update(description: "Permite eliminar promociones existentes.")
Permission.find_by(subject_class: "Folder", action: "set_ready_state").update(description: "Permite activar la promosa de compraventa de un expediente.")

Permission.find_by(subject_class: "Folder", action: "see_all_branches").update(description: "Elimina la restricción que hace que el usuario solo pueda ver expedientes de su misma sucursal.")

Permission.find_by(subject_class: "Permission", action: "create").update(description: "Permite acceder al formulario para crear permisos.")
Permission.find_by(subject_class: "Permission", action: "read").update(description: "Permite acceder a la lista de permisos.")
Permission.find_by(subject_class: "Permission", action: "update").update(description: "Permite editar los permisos existentes.")
Permission.find_by(subject_class: "Permission", action: "destroy").update(description: "Permite eliminar permisos existentes sin asignar.")

Permission.find_by(subject_class: "Signer", action: "read").update(description: "Permite acceder a la lista de firmantes.")
Permission.find_by(subject_class: "Signer", action: "create").update(description: "Permite acceder al formulario para crear firmantes.")
Permission.find_by(subject_class: "Signer", action: "update").update(description: "Permite editar los firmantes existentes.")
Permission.find_by(subject_class: "Signer", action: "destroy").update(description: "Permite eliminar firmantes existentes sin asignar.")

Permission.find_by(subject_class: "Evaluation", action: "create").update(description: "Permite acceder al formulario para crear evaluaciones.")
Permission.find_by(subject_class: "Evaluation", action: "read").update(description: "Permite acceder a la lista de evaluaciones.")
Permission.find_by(subject_class: "Evaluation", action: "update").update(description: "Permite editar las evaluaciones existentes.")
Permission.find_by(subject_class: "Evaluation", action: "destroy").update(description: "Permite eliminar evaluaciones existentes sin respuestas.")

Permission.find_by(subject_class: "Step", action: "create").update(name: "Crear", description: "Permite crear pasos en el pipeline.")
Permission.find_by(subject_class: "Step", action: "read").update(name: "Ver", description: "Permite ver los pasos del pipeline en el catálogo.")
Permission.find_by(subject_class: "Step", action: "update").update(name: "Editar", description: "Permite editar el nombre y permisos de los pasos en el pipeline.")
Permission.find_by(subject_class: "Step", action: "destroy").update(name: "Eliminar", description: "Permite eliminar pasos del pipeline, esto sólo se permite si el paso no tiene expedientes.")
Permission.find_by(subject_class: "Step", action: "read_step_log").update(name: "Leer bitácora", description: "Permite visualizar la línea de tiempo del expediente.")
Permission.find_by(subject_class: "Step", action: "see_deleted").update(name: "Ver eliminados", description: "Permite visualizar los pasos previamente eliminados.")
Permission.find_by(subject_class: "Step", action: "sort").update(name: "Reordenar", description: "Permite reordenar los pasos del pipeline.")
