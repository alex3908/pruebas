# frozen_string_literal: true

module CommentsHelper
  def comment_header(comment)
    "#{tag.strong(comment.user.label, class: "text-info")} comentó ".html_safe
  end

  def comment_timestamp(comment)
    "el día #{comment.created_at.strftime("%d/%m/%Y")} a las #{comment.created_at.strftime("%I:%M:%S %p")}"
  end
end
