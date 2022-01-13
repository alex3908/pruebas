# frozen_string_literal: true

class FrequentQuestionSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :link, :status, :user_id
end
