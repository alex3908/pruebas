# frozen_string_literal: true

class ClientsApi::V1::FrequentQuestionSerializer < ClientsApi::V1::BaseSerializer
  attributes :id, :creator, :title, :content, :link, :status

  def creator
    User.find(object.user_id).label
  end
end
