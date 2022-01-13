# frozen_string_literal: true

module PlanManager
  def get_plan
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def create_plan
    raise NotImplementedError, "#{self.class} has not implemented"
  end

  def update_plan_amount
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
