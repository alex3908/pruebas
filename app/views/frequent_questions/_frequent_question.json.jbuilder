# frozen_string_literal: true

json.extract! frequent_question, :id, :title, :content, :url, :status, :user_id, :created_at, :updated_at
json.url frequent_question_url(frequent_question, format: :json)
