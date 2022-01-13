# frozen_string_literal: true

class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  scope :permitted, ->(is_permitted) do
    if is_permitted
      all
    else
      where(hidden: false)
    end
  end

  def self.search(params)
    permissions = Permission.all
    permissions = permissions.where("LOWER(name) LIKE LOWER(?)", "%#{params[:name]}%") if params[:name].present?
    permissions = permissions.where("LOWER(subject_class) LIKE LOWER(?)", "%#{params[:subject_class]}%") if params[:subject_class].present?
    permissions = permissions.where("LOWER(action) LIKE LOWER(?)", "%#{params[:action_permission]}%") if params[:action_permission].present?
    permissions
  end

  def action_sym
    action.to_sym
  end

  def subject_sym
    if subject_class.start_with?(":")
      subject_class[1..-1].to_sym
    else
      subject_class.constantize
    end
  rescue Exception
    puts "NameError: wrong constant name #{subject_class}"
  end
end
