# frozen_string_literal: true

class NullJobStatus
  def initialize(folder_number)
    @folder_number = folder_number
  end

  def add_progress!(message)
    message
  end

  def mark_completed!
    true
  end
  def mark_failed!(message)
    message
  end

  def log_error!(message)
    message
  end
  def file_name
    "Promesa de compraventa Exp #{@folder_number} - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}"
  end

  def file
    nil
  end
end
