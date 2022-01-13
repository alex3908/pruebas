# frozen_string_literal: true

module BaseService
  def get_fields
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
