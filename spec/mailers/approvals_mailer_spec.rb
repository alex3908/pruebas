# frozen_string_literal: true

RSpec.describe ApprovalsMailer, type: :mailer do
  before(:all) do
    @user = create(:user)
  end


  describe "#send_approved" do
    let(:mail) { described_class.send_approved(@user).deliver_now }

    it "renders the subject" do
      expect(mail.subject).to eql("Tu cuenta ha sido aprobada")
    end
  end
end
