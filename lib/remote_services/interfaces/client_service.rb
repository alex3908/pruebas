# frozen_string_literal: true

module ClientService
  def get_client
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
