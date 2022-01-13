# frozen_string_literal: true

json.array! @frequent_questions, partial: "frequent_questions/frequent_question", as: :frequent_question
