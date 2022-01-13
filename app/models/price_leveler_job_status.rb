# frozen_string_literal: true

class PriceLevelerJobStatus < JobStatus
  default_scope { price_leveler }

  def initialize(date:, user:, stage_ids:, price:)
    super(
      job_class: :price_leveler,
      name: "Nivelación de precio - #{date}",
      user: user,
      status: :pending,
      action: :task,
      description: "Actualización de precios a realizar el #{date}",
      job_data: {
        date: date,
        stage_ids: stage_ids,
        price: price
      }
    )
  end

  def scheduled_date
    DateTime.parse(data[:date]) if data[:date].present?
  end

  def stages
    return JobStatus.none if data[:stage_ids].nil?

    Stage.where(id: JSON.parse(data[:stage_ids]))
  end

  def price
    data[:price]&.to_f || ""
  end

  private

    def data
      HashWithIndifferentAccess.new(self.job_data) || {}
    end
end
