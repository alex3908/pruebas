# frozen_string_literal: true

module ConfirmService
  def confirm
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
