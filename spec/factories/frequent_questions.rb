# frozen_string_literal: true

FactoryBot.define do
  factory :frequent_question do
    title { "Pregunta Frecuente" }
    content { "Contenido sobre preguntas frecuentes" }
    url { "orve.com.mx" }
    status { 0 }
    user_id { 1 }
  end
end
