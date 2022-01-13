# frozen_string_literal: true

module EvaluationsHelper
  def translate_evaluation_type(evaluation_type)
    evaluation_type == "approve" ? "Aprobación" : "Rechazo"
  end
end
