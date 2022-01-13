# frozen_string_literal: true

Evaluation.create_with(active: true).find_or_create_by(question: "Los datos generales están incompletos o incorrectos", question_type: "reject")
Evaluation.create_with(active: true).find_or_create_by(question: "Documentación incompleta", question_type: "reject")
Evaluation.create_with(active: true).find_or_create_by(question: "Documentación ilegible", question_type: "reject")
Evaluation.create_with(active: true).find_or_create_by(question: "Documentación incorrecta", question_type: "reject")
Evaluation.create_with(active: true).find_or_create_by(question: "Carpeta física incompleta", question_type: "reject")
Evaluation.create_with(active: true).find_or_create_by(question: "¿El llenado de los generales del cliente fue correcto?", question_type: "approve")
Evaluation.create_with(active: true).find_or_create_by(question: "¿La carpeta física fue debidamente marcada?", question_type: "approve")
Evaluation.create_with(active: true).find_or_create_by(question: "¿La carpeta física fue debidamente identificada?", question_type: "approve")
Evaluation.create_with(active: true).find_or_create_by(question: "¿Los recibos firmados coinciden con los pagos del cliente?", question_type: "approve")
Evaluation.create_with(active: true).find_or_create_by(question: "¿Los documentos son legibles?", question_type: "approve")
Evaluation.create_with(active: true).find_or_create_by(question: "¿Los documentos se subieron en los campos a los que corresponden en el sistema?", question_type: "approve")
