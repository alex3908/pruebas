# frozen_string_literal: true

class SignatureService
  attr_accessor :properties
  attr_accessor :environment

  def initialize(properties, environment = "test")
    @properties = properties
    @environment = environment
  end

  def init_process
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def environment?(arg)
    arg.to_s == environment
  end
end
