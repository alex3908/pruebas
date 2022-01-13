# frozen_string_literal: true

class SupportSaleMailerPreview < ActionMailer::Preview
  def support_notification
    SupportSaleMailer.support_notification(Folder.first, FactoryBot.build(:user), SupportSale.first)
  end

  def support_assigned_notification
    support_sale = SupportSale.first
    folder = Folder.first
    SupportSaleMailer.support_assigned_notification(folder.client.email, folder, support_sale, support_sale.supporter.label, support_sale.support_coordinator.label, support_sale.support_manager.label)
  end

  def support_rejected_notification
    support_sale = SupportSale.first
    folder = Folder.first
    SupportSaleMailer.support_rejected_notification(folder.client.email, support_sale.request_manager.label, support_sale.support_manager.label, support_sale.requester.label, support_sale)
  end
end
