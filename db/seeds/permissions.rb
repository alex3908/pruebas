# frozen_string_literal: true

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Role", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Role", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Role", action: "update")
Permission.create_with(name: "Cambiar permisos").find_or_create_by(subject_class: "Role", action: "permission_to")
Permission.create_with(name: "Ver ocultos").find_or_create_by(subject_class: "Role", action: "view_hidden")
Permission.create_with(name: "Modificar reglas de cotizador", description: "Permite al usuario crear o modificar las reglas en el cotizador para roles específicos").find_or_create_by(subject_class: "Role", action: "custom_quote_permissions")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Project", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Project", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Project", action: "update")
Permission.create_with(name: "Cambiar estado").find_or_create_by(subject_class: "Project", action: "status")
Permission.create_with(name: "Ordenar proyectos").find_or_create_by(subject_class: "Project", description: "Permite ordenar los proyectos", action: "sort")
Permission.create_with(name: "Importar proyectos").find_or_create_by(subject_class: "Project", action: "import")
Permission.create_with(name: "Exportar proyectos").find_or_create_by(subject_class: "Project", action: "export")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "User", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "User", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "User", action: "update")
Permission.create_with(name: "Habilitar privadas").find_or_create_by(subject_class: "User", action: "assignment")
Permission.create_with(name: "Cambiar contrase\u00F1a").find_or_create_by(subject_class: "User", action: "change_password")
Permission.create_with(name: "Activar Usuario").find_or_create_by(subject_class: "User", action: "activate_user")
Permission.create_with(name: "Generar Reporte").find_or_create_by(subject_class: "User", action: "report")
Permission.create_with(name: "Pretender").find_or_create_by(subject_class: "User", action: "become")
Permission.create_with(name: "Acceder a la bitácora").find_or_create_by(subject_class: "User", action: "see_binnacle")
Permission.create_with(name: "Solo acceder a asesor").find_or_create_by(subject_class: "User", action: "see_sellers")
Permission.create_with(name: "Verificar documentación de usuario").find_or_create_by(subject_class: "User", action: "verify_user_file")
Permission.create_with(name: "Editar Referido", description: "Permite editar un referido.").find_or_create_by(subject_class: "User", action: "update_referrer")
Permission.create_with(name: "Seleccionar Referido", description: "Permite elegir un referido al crear un usuario.").find_or_create_by(subject_class: "User", action: "select_referrer")
Permission.create_with(name: "Cambiar sucursal").find_or_create_by(subject_class: "User", action: "change_branch")
Permission.create_with(name: "Eliminar bloqueo email").find_or_create_by(subject_class: "User", action: "delete_suppression")

Permission.find_by(subject_class: "User", action: "create_realtor").try(:destroy)
Permission.find_by(subject_class: "User", action: "create_coordinator").try(:destroy)
Permission.find_by(subject_class: "User", action: "create_manager").try(:destroy)
Permission.find_by(subject_class: "User", action: "create_vice_director").try(:destroy)
Permission.find_by(subject_class: "User", action: "create_director").try(:destroy)
Permission.find_by(subject_class: "User", action: "create_salesman").try(:destroy)


Permission.create_with(name: "Crear", description: "Permite acceder al formulario para crear privadas.").find_or_create_by(subject_class: "Stage", action: "create")
Permission.create_with(name: "Acceder", description: "Permite acceder a la lista de privadas. *Necesita acceso a las etapas").find_or_create_by(subject_class: "Stage", action: "read")
Permission.create_with(name: "Editar", description: "Permite editar las privadas existentes.").find_or_create_by(subject_class: "Stage", action: "update")
Permission.create_with(name: "Cambiar estado", description: "Permite activar o desactivar privadas. (Depende de la venta de 90%)").find_or_create_by(subject_class: "Stage", action: "status")
Permission.create_with(name: "Cambiar estado sin considerar 90%", description: "Permite activar o desactivar privadas. (No limitado 90%)").find_or_create_by(subject_class: "Stage", action: "force_activate")

Permission.create_with(name: "Ordenar etapas").find_or_create_by(subject_class: "Stage", description: "Permite ordenar las etapas", action: "sort")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Phase", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Phase", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Phase", action: "update")
Permission.create_with(name: "Ordenar fases").find_or_create_by(subject_class: "Phase", description: "Permite ordenar las fases", action: "sort")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Lot", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Lot", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Lot", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "Lot", action: "destroy")
Permission.find_by(subject_class: "Lot", action: "report").try(:destroy)

Permission.create_with(name: "Bloquear/desbloquear inventario").find_or_create_by(subject_class: "Lot", action: "lock")

Permission.find_by(subject_class: "Lot", action: "import").try(:destroy)

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Client", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Client", action: "read")
Permission.create_with(name: "Acceder a Todos", description: "Permite ver todos los clientes indistintamente de si pertenecen al usuario").find_or_create_by(subject_class: "Client", action: "see_all")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Client", action: "update")
Permission.create_with(name: "Acceder a la bitácora").find_or_create_by(subject_class: "Client", action: "see_binnacle")
Permission.create_with(name: "Puede Renombrar").find_or_create_by(subject_class: "Client", action: "rename")
Permission.create_with(name: "Puede cambiar el correo").find_or_create_by(subject_class: "Client", action: "edit_email")
Permission.create_with(name: "Eliminar bloqueo email").find_or_create_by(subject_class: "Client", action: "delete_suppression")

Permission.find_by(subject_class: "Client", action: "report").try(:destroy)

Permission.create_with(name: "Subir archivos API").find_or_create_by(subject_class: "Client", action: "upload_files")
Permission.create_with(name: "Importar").find_or_create_by(subject_class: "Client", action: "import")
Permission.create_with(name: "Reasignación masiva").find_or_create_by(subject_class: "Client", action: "mass_reassign")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "BankAccount", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "BankAccount", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "BankAccount", action: "update")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Enterprise", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Enterprise", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Enterprise", action: "update")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Branch", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Branch", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Branch", action: "update")

Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Folder", action: "read")
Permission.create_with(name: "Cambiar tipo de expediente").find_or_create_by(subject_class: "Folder", action: "change_buyer")
Permission.create_with(name: "Acceder a Todos").find_or_create_by(subject_class: "Folder", action: "see_all")
Permission.create_with(name: "Importar Tablas de amortización").find_or_create_by(subject_class: "Folder", action: "import_amortization")
Permission.create_with(name: "Acceder a la gráfica de ventas", description: "Permite visualizar la gráfica de barras de ventas en el índice de reportes")
  .find_or_create_by(subject_class: "Folder", action: "read_sales_chart")
Permission.create_with(name: "Acceder a la sección de cuotas personalizadas", description: "Permite crear o editar letras de pagos").find_or_create_by(subject_class: "Folder", action: "custom_installments")
Permission.create_with(name: "Generar Reporte").find_or_create_by(subject_class: "Folder", action: "report")
Permission.find_by(subject_class: "Folder", action: "revise").try(:destroy)
Permission.find_by(subject_class: "Folder", action: "cancel_revision").try(:destroy)
Permission.find_by(subject_class: "Folder", action: "update_revision").try(:destroy)
Permission.find_by(subject_class: "Folder", action: "finish").try(:destroy)
Permission.find_by(subject_class: "Folder", action: "cancel").try(:destroy)
Permission.find_by(subject_class: "Folder", action: "cancel_accepted").try(:destroy)
Permission.find_by(subject_class: "Folder", action: "revision").try(:destroy)
Permission.find_by(subject_class: "Folder", action: "reassign_seller").try(:destroy)
Permission.find_by(subject_class: "Folder", action: "reassign_client").try(:destroy)

Permission.create_with(name: "Acceder a la Promesa con Anexo").find_or_create_by(subject_class: "Folder", action: "purchase_promise")
Permission.create_with(name: "Acceder a la bitácora").find_or_create_by(subject_class: "Folder", action: "see_binnacle")
Permission.create_with(name: "Descargar plantillas del proyecto").find_or_create_by(subject_class: "Folder", action: "download_templates")
Permission.create_with(name: "Reactivar").find_or_create_by(subject_class: "Folder", action: "reactivate")
Permission.find_by(subject_class: "Folder", action: "cancel_active").try(:destroy)
Permission.find_by(subject_class: "Folder", action: "cancel_approved").try(:destroy)
Permission.find_by(subject_class: "Folder", action: "update_active").try(:destroy)
Permission.find_by(subject_class: "Folder", action: "update_approved").try(:destroy)
Permission.create_with(name: "Cancelar expedientes finalizados con pagos").find_or_create_by(subject_class: "Folder", action: "cancel_approved_with_payments")
Permission.find_by(subject_class: "Folder", action: "force_approve").try(&:destroy)
Permission.find_by(subject_class: "Folder", action: "force_accepted").try(&:destroy)
Permission.create_with(name: "Solicitar soporte").find_or_create_by(subject_class: "Folder", action: "request_support", description: "Crea una solicitud para asignar un asesor de soporte con el fin de realizar comisiones cruzadas en una venta/expediente.")
Permission.create_with(name: "Subir archivos API").find_or_create_by(subject_class: "Folder", action: "upload_files")
Permission.create_with(name: "Ver pagos de expedientes API").find_or_create_by(subject_class: "Folder", action: "folders_payments")
Permission.create_with(name: "Ver pagos de un expediente API").find_or_create_by(subject_class: "Folder", action: "folder_payments")
Permission.create_with(name: "Carteras por vencer API").find_or_create_by(subject_class: "Folder", action: "balances_close_to_due")
Permission.create_with(name: "Cartera por vencer de un expediente API").find_or_create_by(subject_class: "Folder", action: "folder_balances_close_to_due")
Permission.create_with(name: "Detalle de expedientes API").find_or_create_by(subject_class: "Folder", action: "folders_information")
Permission.create_with(name: "Detalle de expediente API").find_or_create_by(subject_class: "Folder", action: "folder_information")
Permission.create_with(name: "Acceder a la bitácora de firmas digitales").find_or_create_by(subject_class: "Folder", action: "show_digital_signature_logs")
Permission.create_with(name: "Forzar cancelación de firma digital").find_or_create_by(subject_class: "Folder", action: "force_cancel_digital_signature")

# Remove old permissions if they exist
folder_user_old_permissions = Array.new
folder_user_old_permissions << Permission.find_by(subject_class: "FolderUser", action: "create")
folder_user_old_permissions << Permission.find_by(subject_class: "FolderUser", action: "update")
folder_user_old_permissions << Permission.find_by(subject_class: "FolderUser", action: "destroy")
folder_user_old_permissions.compact.each(&:destroy)

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Contract", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Contract", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Contract", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "Contract", action: "destroy")
Permission.create_with(name: "Acceder a la bitácora").find_or_create_by(subject_class: "Contract", action: "see_binnacle")
Permission.create_with(name: "Crear promesa de compra venta personalizada").find_or_create_by(subject_class: "Contract", action: "custom_create")
Permission.create_with(name: "Editar promesa de compra venta personalizada").find_or_create_by(subject_class: "Contract", action: "custom_update")
Permission.create_with(name: "Eliminar promesa de compra venta personalizada").find_or_create_by(subject_class: "Contract", action: "custom_destroy")
Permission.create_with(name: "Acceder a promesas de compra venta personalizadas").find_or_create_by(subject_class: "Contract", action: "custom_index")

Permission.where(subject_class: "PaymentPlan").update_all(subject_class: "Discount")
Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Discount", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Discount", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Discount", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "Discount", action: "destroy")

Permission.find_by(subject_class: "Folder", action: "update_files").try(:destroy)
update_files_folder = Permission.find_by(subject_class: "Folder", action: "update_files")
if update_files_folder.present?
  update_files_folder.name = "Manipular archivos (Activo)" if update_files_folder.name == "Manipular archivos"
  update_files_folder.save
end
Permission.find_by(subject_class: "Folder", action: "approved_update_files").try(:destroy)
Permission.create_with(name: "Ver fecha modificación de archivos").find_or_create_by(subject_class: "Folder", action: "read_files_date")
Permission.create_with(name: "Extender expiración").find_or_create_by(subject_class: "Folder", action: "extend")

Permission.create_with(name: "Generar cotización", description: "Permite a los usuarios generar cotizaciones.").find_or_create_by(subject_class: ":quote", action: "quote")
Permission.create_with(name: "Reservar sobre cotización", description: "Permite a los usuarios generar las reservas sobre una cotización. Es necesario activar el permiso de Cotizar.").find_or_create_by(subject_class: ":quote", action: "reserve")
Permission.find_by(subject_class: ":quote", action: "reserve_without_file").try(&:destroy)
Permission.find_by(subject_class: ":quote", action: "edit_with_files").try(&:destroy)
Permission.create_with(name: "Agregar descuento personalizado", description: "Permite agregar un descuento personalizado al editar una cotización").find_or_create_by(subject_class: ":quote", action: "custom_discount")
Permission.create_with(name: "Editar precio por metro cuadrado", description: "Permite editar el precio por metro cuadrado en una cotización").find_or_create_by(subject_class: ":quote", action: "custom_buy_price")
Permission.create_with(name: "Editar meses sin intereses", description: "Permite editar los meses sin intereses en una cotización").find_or_create_by(subject_class: ":quote", action: "custom_zero_rate")
Permission.create_with(name: "Modificar meses de gracia", description: "Permite editar los meses de gracia en una cotización").find_or_create_by(subject_class: ":quote", action: "custom_start_installments")
Permission.create_with(name: "Agregar promoción", description: "Permite agregar una promoción especial en una cotización").find_or_create_by(subject_class: ":quote", action: "custom_promotion")
Permission.create_with(name: "Editar esquema de crédito", description: "Permite editar el esquema de crédito en una cotización").find_or_create_by(subject_class: ":quote", action: "custom_credit")
Permission.create_with(name: "Editar dias para primer pago", description: "Permite editar el primer pago sin tener validaciones en una cotización").find_or_create_by(subject_class: ":quote", action: "custom_first_payment")
Permission.create_with(name: "Editar plazo de enganche sin validación", description: "Permite editar el plazo de enganche sin tener validaciones en una cotización").find_or_create_by(subject_class: ":quote", action: "custom_down_payment_finance")
Permission.create_with(name: "Editar cantidad de enganche sin validación", description: "Permite editar cantidad de enganche sin tener validaciones en una cotización").find_or_create_by(subject_class: ":quote", action: "custom_down_payment_amount")
Permission.create_with(name: "Editar apartado sin validación", description: "Permite editar el apartado sin tener validaciones en una cotización").find_or_create_by(subject_class: ":quote", action: "custom_initial_payment")
Permission.find_by(subject_class: ":quote", action: "custom_approved_date").try(&:destroy)
Permission.create_with(name: "Editar fecha de inicio", description: "Permite editar la fecha de inicio del expediente").find_or_create_by(subject_class: ":quote", action: "custom_start_date")
Permission.create_with(name: "Editar si el expediente es comisionable", description: "Permite editar si el expediente es comisionable").find_or_create_by(subject_class: ":quote", action: "custom_commissionable")
Permission.create_with(name: "Personalizar metros cuadrados", description: "Permite añadir un metraje diferente del lote al expediente, con el fin de solventar una diferencia.").find_or_create_by(subject_class: ":quote", action: "custom_area")

Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "CashFlow", action: "read")
Permission.create_with(name: "Cancelar").find_or_create_by(subject_class: "CashFlow", action: "cancel")
Permission.create_with(name: "Reenviar notificación", description: "Permite reenviar el comprobante de pago al cliente").find_or_create_by(subject_class: "CashFlow", action: "resend_notification")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "PaymentMethod", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "PaymentMethod", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "PaymentMethod", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "PaymentMethod", action: "destroy")

Permission.create_with(name: "Crear", description: "Permite crear tipos identificaciones oficiales.").find_or_create_by(subject_class: "IdentificationType", action: "create")
Permission.create_with(name: "Acceder", description: "Permite acceder al listado tipos identificaciones oficiales.").find_or_create_by(subject_class: "IdentificationType", action: "read")
Permission.create_with(name: "Editar", description: "Permite editar los tipos identificaciones oficiales.").find_or_create_by(subject_class: "IdentificationType", action: "update")
Permission.create_with(name: "Eliminar", description: "Permite eliminar los tipos identificaciones oficiales.").find_or_create_by(subject_class: "IdentificationType", action: "destroy")

Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Commission", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Commission", action: "update")
Permission.create_with(name: "Importar").find_or_create_by(subject_class: "Commission", action: "import")



Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Structure", action: "read")
Permission.create_with(name: "Aprobar equipos", description: "Permite aprobar o rechazar niveles de ventas.").find_or_create_by(subject_class: "Structure", action: "approval")
Permission.create_with(name: "Modificar estructura", description: "Permite asignar o retirar a los responsables de los niveles.").find_or_create_by(subject_class: "Structure", action: "hire_and_fire")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "Structure", action: "destroy")
Permission.create_with(name: "Afiliar", description: "Permite la afiliación de un usuario existente a un nuevo nivel").find_or_create_by(subject_class: "Structure", action: "affiliated_user")
Permission.create_with(name: "Crear", description: "Permite la creación de un nuevo usuario en un nivel.").find_or_create_by(subject_class: "Structure", action: "create_user")
Permission.create_with(name: "Configurar rol", description: "Permite la configuración del rol que tendrá un nodo en el multinivel.").find_or_create_by(subject_class: "Structure", action: "set_level_to_role")
Permission.create_with(name: "Configuraciones del nivel", description: "Permite actualizar las configuración del nivel.").find_or_create_by(subject_class: "Structure", action: "see_level_configurations_modal")
Permission.create_with(name: "Reenviar invitación", description: "Permite reenviar la invitación al usuario de la estructura.").find_or_create_by(subject_class: "Structure", action: "resend_invitation")
Permission.create_with(name: "Restablecer contraseña", description: "Permite restablecer la contraseña del usuario de la estructura.").find_or_create_by(subject_class: "Structure", action: "reset_password")

Permission.find_by(subject_class: "Structure", action: "hire").try(:destroy)
Permission.find_by(subject_class: "Structure", action: "fire").try(:destroy)
Permission.find_by(subject_class: "Structure", action: "edit").try(:destroy)
Permission.find_by(subject_class: "Structure", action: "see_binnacle").try(:destroy)
Permission.find_by(subject_class: ":approval", action: "show").try(:destroy)



Permission.create_with(name: "Personalizar la fecha de pago").find_or_create_by(subject_class: "Installment", action: "set_date")
Permission.create_with(name: "Estado de Cuenta").find_or_create_by(subject_class: "Installment", action: "account_status")
Permission.create_with(name: "Nuevo pago").find_or_create_by(subject_class: "Installment", action: "new_payment")
Permission.create_with(name: "Nuevo abono a capital").find_or_create_by(subject_class: "Installment", action: "new_capital")
Permission.create_with(name: "Nueva restructura de saldo").find_or_create_by(subject_class: "Installment", action: "new_restructure")
Permission.create_with(name: "Cambio de fecha").find_or_create_by(subject_class: "Installment", action: "new_date")
Permission.create_with(name: "Nueva Prórroga").find_or_create_by(subject_class: "Installment", action: "new_delay")
Permission.create_with(name: "Pago de servicios adicionales", description: "Permite realizar el pago de servicios adicionales").find_or_create_by(subject_class: "Installment", action: "new_additional_concept_payment")
Permission.create_with(name: "Enviar recordatorio de pago", description: "Permite enviar un correo de recordatorio de pago").find_or_create_by(subject_class: "Installment", action: "mail_payment_due_soon")

Permission.find_by(subject_class: "Installment", action: "read").try(:destroy)

create_installment = Permission.find_by(subject_class: "Installment", action: "create_payment")
if create_installment.present?
  create_installment.action = "create"
  create_installment.save
else
  Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Installment", action: "create")
end

Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Setting", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Setting", action: "update")
Permission.create_with(name: "Ver ocultos").find_or_create_by(subject_class: "Setting", action: "view_hidden")

Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Promotion", action: "read")
Permission.create_with(name: "Agregar").find_or_create_by(subject_class: "Promotion", action: "create")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Promotion", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "Promotion", action: "destroy")
Permission.create_with(name: "Activar").find_or_create_by(subject_class: "Promotion", action: "activate_promotion")
Permission.create_with(name: "Activar Promesa de Compra").find_or_create_by(subject_class: "Folder", action: "set_ready_state")

Permission.create_with(name: "Ver todas las sucursales").find_or_create_by(subject_class: "Folder", action: "see_all_branches")

Permission.find_by(subject_class: "Folder", action: "verify_folder_file").try(:destroy)
Permission.find_by(subject_class: "FileApproval", action: "read").try(:destroy)
Permission.find_by(subject_class: "FileApproval", action: "update").try(:destroy)

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Permission", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Permission", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Permission", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "Permission", action: "destroy")
Permission.create_with(name: "Ver ocultos").find_or_create_by(subject_class: "Permission", action: "view_hidden")

Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Signer", action: "read")
Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Signer", action: "create")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Signer", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "Signer", action: "destroy")

Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "LeadSource", action: "read")
Permission.create_with(name: "Crear").find_or_create_by(subject_class: "LeadSource", action: "create")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "LeadSource", action: "update")
Permission.create_with(name: "Activar").find_or_create_by(subject_class: "LeadSource", action: "activate")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "LeadSource", action: "destroy")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Evaluation", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Evaluation", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Evaluation", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "Evaluation", action: "destroy")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "CreditScheme", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "CreditScheme", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "CreditScheme", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "CreditScheme", action: "destroy")
Permission.create_with(name: "Cambiar estado").find_or_create_by(subject_class: "CreditScheme", action: "change_status")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Period", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Period", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Period", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "Period", action: "destroy")
Permission.find_by(subject_class: "Period", action: "create").try(:destroy)
Permission.find_by(subject_class: "Period", action: "read").try(:destroy)
Permission.find_by(subject_class: "Period", action: "update").try(:destroy)
Permission.find_by(subject_class: "Period", action: "destroy").try(:destroy)

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Tag", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Tag", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Tag", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "Tag", action: "destroy")
Permission.create_with(name: "Cambiar estado").find_or_create_by(subject_class: "Tag", action: "change_status")

Permission.create_with(name: "Importar correcciones").find_or_create_by(subject_class: "Stage", action: "import_corrections")
Permission.create_with(name: "Importar carga inicial").find_or_create_by(subject_class: "Stage", action: "import_charges")

Permission.create_with(name: "Agregar pagaré").find_or_create_by(subject_class: "Folder", action: "upload_promissory_note")

Permission.create_with(name: "Enviar correo para domiciliar").find_or_create_by(subject_class: "Subscription", action: "create")
Permission.create_with(name: "Enviar correo para actualizar datos bancarios").find_or_create_by(subject_class: "Subscription", action: "update")
Permission.create_with(name: "Cancelar").find_or_create_by(subject_class: "Subscription", action: "destroy")

Permission.find_by(subject_class: "NetpayService", action: "new").try(:destroy)
Permission.find_by(subject_class: "NetpayService", action: "read").try(:destroy)
Permission.find_by(subject_class: "NetpayService", action: "update").try(:destroy)
Permission.find_by(subject_class: "NetpayService", action: "destroy").try(:destroy)

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "CashBack", action: "create")
Permission.create_with(name: "Cancelar").find_or_create_by(subject_class: "CashBack", action: "cancel")

Permission.create_with(name: "Reporte de comisiones").find_or_create_by(subject_class: ":report", action: "commissions")
Permission.create_with(name: "Reporte de responsables").find_or_create_by(subject_class: ":report", action: "folder_users")
Permission.create_with(name: "Reporte de pagos").find_or_create_by(subject_class: ":report", action: "payments")
Permission.create_with(name: "Reporte de cartera vencida").find_or_create_by(subject_class: ":report", action: "overdue_balances")
Permission.create_with(name: "Reporte de verificaciones").find_or_create_by(subject_class: ":report", action: "file_approvals")
Permission.create_with(name: "Reporte de cartera por vencer").find_or_create_by(subject_class: ":report", action: "balances_close_to_due")
Permission.create_with(name: "Reporte de pipeline").find_or_create_by(subject_class: ":report", action: "step")
Permission.create_with(name: "Reporte de prórrogas").find_or_create_by(subject_class: ":report", action: "delays")
Permission.create_with(name: "Reporte de flujo de caja proyectado").find_or_create_by(subject_class: ":report", action: "future_cash_flow")
Permission.create_with(name: "Reporte de pagos de servicios adicionales", description: "Reporte de ingresos por pagos de servicios adicionales").find_or_create_by(subject_class: ":report", action: "additional_concept_payments")
Permission.create_with(name: "Reporte de dispersión de comisiones").find_or_create_by(subject_class: ":report", action: "commision_dispersion")
Permission.create_with(name: "Reporte de tickets de pago").find_or_create_by(subject_class: ":report", action: "online_payment_tickets")
Permission.create_with(name: "Reporte de unidades").find_or_create_by(subject_class: ":report", action: "units")
Permission.create_with(name: "Reporte de expedientes").find_or_create_by(subject_class: ":report", action: "folders")
Permission.create_with(name: "Reporte de clientes").find_or_create_by(subject_class: ":report", action: "clients")
Permission.create_with(name: "Reporte de usuarios").find_or_create_by(subject_class: ":report", action: "users")
Permission.create_with(name: "Reporte de usuarios referidos").find_or_create_by(subject_class: ":report", action: "referred_users")
Permission.create_with(name: "Reporte KPI").find_or_create_by(subject_class: ":report", action: "users_kpi")
Permission.create_with(name: "Reporte de cotizaciones").find_or_create_by(subject_class: ":report", action: "quote_logs")
Permission.create_with(name: "Reporte de clientes referidos").find_or_create_by(subject_class: ":report", action: "referred_clients")
Permission.create_with(name: "Reporte de ventas realizadas").find_or_create_by(subject_class: ":report", action: "sales")

Permission.create_with(name: "Crear", description: "Permite crear pasos en el pipeline.").find_or_create_by(subject_class: "Step", action: "create")
Permission.create_with(name: "Ver", description: "Permite ver los pasos del pipeline en el catálogo.").find_or_create_by(subject_class: "Step", action: "read")
Permission.create_with(name: "Editar", description: "Permite editar el nombre y permisos de los pasos en el pipeline.").find_or_create_by(subject_class: "Step", action: "update")
Permission.create_with(name: "Eliminar", description: "Permite eliminar pasos del pipeline, esto sólo se permite si el paso no tiene expedientes.").find_or_create_by(subject_class: "Step", action: "destroy")
Permission.create_with(name: "Leer bitácora", description: "Permite visualizar la línea de tiempo del expediente.").find_or_create_by(subject_class: "Step", action: "read_step_log")
Permission.create_with(name: "Ver eliminados", description: "Permite visualizar los pasos previamente eliminados.").find_or_create_by(subject_class: "Step", action: "see_deleted")
Permission.create_with(name: "Reordenar", description: "Permite reordenar los pasos del pipeline.").find_or_create_by(subject_class: "Step", action: "sort")
Permission.create_with(name: "Bloquear", description: "Permite bloquear la asignación de expedientes al paso.").find_or_create_by(subject_class: "Step", action: "block")

Permission.create_with(name: "Crear Plantillas de Documentos", description: "permite al usuario crear nuevas plantillas de documentos").find_or_create_by(subject_class: "DocumentTemplate", action: "create")
Permission.create_with(name: "Ver Plantillas de Documentos", description: "permite al usuario acceder a las plantillas de documentos").find_or_create_by(subject_class: "DocumentTemplate", action: "read")
Permission.create_with(name: "Editar Plantillas de Documentos", description: "permite al usuario editar las plantillas de documentos").find_or_create_by(subject_class: "DocumentTemplate", action: "update")
Permission.create_with(name: "Eliminar Plantillas de Documentos", description: "permite al usuario eliminar las plantillas de documentos").find_or_create_by(subject_class: "DocumentTemplate", action: "destroy")
Permission.create_with(name: "Verificación de Documentos", description: "Permite al usuario verificar los documentos de los expedientes").find_or_create_by(subject_class: "DocumentTemplate", action: "verify")
Permission.create_with(name: "Ordenar Documentos", description: "Permite al usuario ordenar los documentos de los expedientes").find_or_create_by(subject_class: "DocumentTemplate", action: "sort")

Permission.create_with(name: "Crear Secciones de Documentos", description: "permite al usuario crear nuevas secciones de documentos").find_or_create_by(subject_class: "DocumentSection", action: "create")
Permission.create_with(name: "Ver Secciones de Documentos", description: "permite al usuario acceder a las secciones de documentos").find_or_create_by(subject_class: "DocumentSection", action: "read")
Permission.create_with(name: "Editar Secciones de Documentos", description: "permite al usuario editar las secciones de documentos").find_or_create_by(subject_class: "DocumentSection", action: "update")
Permission.create_with(name: "Eliminar Secciones de Documentos", description: "permite al usuario eliminar las secciones de documentos").find_or_create_by(subject_class: "DocumentSection", action: "destroy")
Permission.create_with(name: "Ordenar Secciones de Documentos", description: "permite al usuario ordenar las secciones de documentos").find_or_create_by(subject_class: "DocumentSection", action: "sort")

Permission.create_with(name: "Añandir penalización").find_or_create_by(subject_class: "Penalty", action: "create")
Permission.create_with(name: "Cancelar penalización").find_or_create_by(subject_class: "Penalty", action: "update")

Permission.create_with(name: "Acceder a la bitácora").find_or_create_by(subject_class: "SupportSale", action: "see_binnacle")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "EmailTemplate", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "EmailTemplate", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "EmailTemplate", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "EmailTemplate", action: "destroy")

Permission.create_with(name: "Importar", description: "Permite al usuario cargar expediente por medio de una plantilla").find_or_create_by(subject_class: "Folder", action: "import")
Permission.create_with(name: "Importar", description: "Permite al usuario cargar flujos de caja por medio de una plantilla").find_or_create_by(subject_class: "CashFlow", action: "import")

Permission.create_with(name: "Ver Ocultos", description: "Permite ver los expedientes Cancelados y Expirados").find_or_create_by(subject_class: "Folder", action: "view_hidden")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "FolderUserConcept", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "FolderUserConcept", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "FolderUserConcept", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "FolderUserConcept", action: "destroy")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Comment", action: "create")
Permission.find_by(subject_class: "Comment", action: "create").try(:destroy)
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "DigitalSignatureService", action: "destroy")
Permission.create_with(name: "Crear").find_or_create_by(subject_class: "OnlinePaymentService", action: "create")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "OnlinePaymentService", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "OnlinePaymentService", action: "destroy")

Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Folder", action: "update")
Permission.create_with(name: "Cargar comprobante").find_or_create_by(subject_class: "CashFlow", action: "update")

Permission.create_with(name: "Crear", description: "Permite acceder al formulario para crear servicios adicionales.").find_or_create_by(subject_class: "AdditionalConcept", action: "create")
Permission.create_with(name: "Acceder", description: "Permite acceder a la lista de servicios adicionales.").find_or_create_by(subject_class: "AdditionalConcept", action: "read")
Permission.create_with(name: "Editar", description: "Permite editar los servicios adicionales existentes.").find_or_create_by(subject_class: "AdditionalConcept", action: "update")
Permission.create_with(name: "Eliminar", description: "Permite eliminar servicios adicionales.").find_or_create_by(subject_class: "AdditionalConcept", action: "destroy")
Permission.create_with(name: "Cambiar estado", description: "Permite activar o desactivar servicios adicionales.").find_or_create_by(subject_class: "AdditionalConcept", action: "change_status")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Coupon", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Coupon", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Coupon", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "Coupon", action: "destroy")
Permission.create_with(name: "Activar").find_or_create_by(subject_class: "Coupon", action: "activate")

Permission.find_by(subject_class: ":sale", action: "referrals").try(:destroy)
Permission.create_with(name: "Acceder", description: "Permite acceder a la lista de usuarios referidos").find_or_create_by(subject_class: ":referent", action: "read")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "CommissionScheme", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "CommissionScheme", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "CommissionScheme", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "CommissionScheme", action: "destroy")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "DownPayment", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "DownPayment", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "DownPayment", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "DownPayment", action: "destroy")
Permission.find_by(subject_class: "DownPayment", action: "create").try(:destroy)
Permission.find_by(subject_class: "DownPayment", action: "read").try(:destroy)
Permission.find_by(subject_class: "DownPayment", action: "update").try(:destroy)
Permission.find_by(subject_class: "DownPayment", action: "destroy").try(:destroy)

Permission.create_with(name: "Ver Responsable").find_or_create_by(subject_class: "Folder", action: "see_folder_users")

Permission.create_with(name: "Aplicar abonos a capital con saldo vencido").find_or_create_by(subject_class: "Installment", action: "apply_capital_with_overdue")

Permission.create_with(name: "Ver expedientes de subordinados").find_or_create_by(subject_class: "Folder", action: "read_subordinate_folders")

Permission.create_with(name: "Crear responsables", description: "Aplica para todos los expedientes.").find_or_create_by(subject_class: "FolderUser", action: "create")
Permission.create_with(name: "Editar responsables", description: "Aplica para todos los expedientes.").find_or_create_by(subject_class: "FolderUser", action: "update")
Permission.create_with(name: "Eliminar responsables", description: "Aplica para todos los expedientes.").find_or_create_by(subject_class: "FolderUser", action: "destroy")

Permission.create_with(name: "Crear responsables en expedientes ocultos", description: "Aplica para los expedientes cancelados y expirados.").find_or_create_by(subject_class: "FolderUser", action: "create_only_hidden")
Permission.create_with(name: "Editar responsables en expedientes ocultos", description: "Aplica para los expedientes cancelados y expirados.").find_or_create_by(subject_class: "FolderUser", action: "update_only_hidden")
Permission.create_with(name: "Eliminar responsables en expedientes ocultos", description: "Aplica para los expedientes cancelados y expirados.").find_or_create_by(subject_class: "FolderUser", action: "destroy_only_hidden")
Permission.create_with(name: "Bitácora del nivelador de precios").find_or_create_by(subject_class: "JobStatus", action: "read_logs")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "Classifier", action: "create")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "Classifier", action: "update")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "Classifier", action: "read")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "ClientUserConcept", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "ClientUserConcept", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "ClientUserConcept", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "ClientUserConcept", action: "destroy")


Permission.find_by(subject_class: "ClientUser", action: "list_users_role").try(:destroy)

Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "ClientUser", action: "read")
Permission.create_with(name: "Crear").find_or_create_by(subject_class: "ClientUser", action: "create")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "ClientUser", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "ClientUser", action: "destroy")
Permission.create_with(name: "Importar").find_or_create_by(subject_class: "ClientUser", action: "import")

Permission.create_with(name: "Cancelar tareas").find_or_create_by(subject_class: "JobStatus", action: "cancel")

Permission.create_with(name: "Nuevo abono a enganche").find_or_create_by(subject_class: "Installment", action: "apply_capital_down_payment")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "ReferredClient", action: "create")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "ReferredClient", action: "read")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "ReferredClient", action: "destroy")
Permission.create_with(name: "Activar autocompletado").find_or_create_by(subject_class: "ReferredClient", action: "autocomplete")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "FrequentQuestion", action: "create")
Permission.create_with(name: "Cambiar estado").find_or_create_by(subject_class: "FrequentQuestion", action: "change_status")
Permission.create_with(name: "Acceder").find_or_create_by(subject_class: "FrequentQuestion", action: "read")
Permission.create_with(name: "Editar").find_or_create_by(subject_class: "FrequentQuestion", action: "update")
Permission.create_with(name: "Eliminar").find_or_create_by(subject_class: "FrequentQuestion", action: "destroy")

Permission.create_with(name: "Crear").find_or_create_by(subject_class: "UserClient", action: "create")
