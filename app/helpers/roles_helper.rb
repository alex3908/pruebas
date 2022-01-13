# frozen_string_literal: true

module RolesHelper
  def permission_group_name_translated
    {
      "BankAccount" => "Cuentas de Banco",
      "Blueprint" => "Planos Interactivos",
      "BlueprintLot" => "Planos Interactivos - Unidades",
      "Branch" => "Sucursales",
      "Classifier" => "Clasificadores",
      "Client" => "Clientes",
      "Comment" => "Comentarios",
      "Contract" => "Contratos",
      "Enterprise" => "Empresas",
      "Folder" => "Expedientes",
      "Log" => "Bitácoras",
      "Lot" => "Unidades",
      "Discount" => "Planes de Pago",
      "Phase" => "Fases",
      "Project" => "Proyectos",
      "ProjectUser" => "Acceso a Proyectos",
      ":quote" => "Cotizador",
      "Role" => "Roles",
      "Stage" => "Etapas",
      "StageUser" => "Acceso a Etapas",
      "User" => "Usuarios",
      "Setting" => "Configuraciones",
      "Installment" => "Pagos",
      "Payment" => "Historial de pagos",
      "PaymentMethod" => "Métodos de pago",
      "Commission" => "Comisiones",
      "Promotion" => "Promociones",
      "Structure" => "Multinivel",
      "Permission" => "Permisos",
      "Evaluation" => "Evaluaciones",
      "Signer" => "Firmantes",
      "FileApproval" => "Aprobaciones de archivos",
      "CreditScheme" => "Crédito",
      "Period" => "Periodos",
      "LeadSource" => "Origenes del cliente",
      "Tag" => "Etiquetas",
      "Subscription" => "Suscripciones",
      "NetpayService" => "Servicios de NetPay",
      "CashBack" => "Bonificación",
      ":report" => "Reportes",
      "FolderUser" => "Responsables",
      "Step" => "Pasos",
      "DocumentTemplate" => "Documentos",
      "DocumentSection" => "Sección de Documentos",
      "Penalty" => "Penalizaciones",
      "EmailTemplate" => "Plantillas de correos",
      "CashFlow" => "Flujos de Caja",
      "FolderUserConcept" => "Conceptos de responsables",
      "FolderUser" => "Responsables",
      "SupportSale" => "Ventas compartidas",
      "DigitalSignatureService" => "Servicios de firmas digitales",
      "OnlinePaymentService" => "Servicios de Cobranza",
      "IdentificationType" => "Tipos de Identificación Oficial",
      "AdditionalConcept" => "Servicios Adicionales",
      ":sale" => "Ventas",
      "Coupon" => "Cupones",
      ":referent" => "Referidos",
      "CommissionScheme" => CommissionScheme.model_name.human,
      "DownPayment" => DownPayment.model_name.human,
      "JobStatus" => "Bitácoras de Jobs",
      "ClientUserConcept" => "Conceptos de clientes",
      "ClientUser" => "Responsables de clientes",
      "ReferredClient" => "Clientes referidos",
      "UserClient" => "Usuarios de app",
      "FrequentQuestion" => "Preguntas frecuentes",
    }
  end

  def permission_group_name(class_name)
    permission_group_name_translated[class_name] || "Sin traducci\u00F3n"
  end

  def setup_role(role)
    role.quote_role ||= QuoteRole.new
    role
  end
end
