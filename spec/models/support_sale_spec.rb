# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportSale, type: :model do
  describe "associations" do
    it { should belong_to(:folder) }
    it { should belong_to(:requester).class_name("User") }
    it { should belong_to(:support_coordinator).class_name("User").optional }
    it { should belong_to(:support_manager).class_name("User").optional }
    it { should belong_to(:supporter).class_name("User").optional }
  end

  describe "validations" do
    # it { should have_one_attached(:crossed_commission_details) }

    it "initializes status to creation" do
      subject.save
      expect(subject.status).to eq("creation")
    end
  end

  describe "requester coordinator and manager" do
    # scenario "salesman requester" do
    #   salesman = User.find_by!(role: salesman_role)
    #   subject.requester = salesman

    #   salesman_coordinator = salesman.structure.staff_structure[:coordinator].user
    #   expect(subject.request_coordinator).to eq(salesman_coordinator)

    #   salesman_manager = salesman.structure.staff_structure[:manager].user
    #   expect(subject.request_manager).to eq(salesman_manager)
    # end

    # scenario "coordinator requester" do
    #   coordinator = User.find_by!(role: coordinator_role)
    #   subject.requester = coordinator

    #   expect(subject.request_coordinator).to eq(coordinator)
    #   expect(subject.request_manager).to eq(coordinator.structure.staff_structure[:manager].user)
    # end
  end

  def salesman_role
    @salesman_role ||= Role.where(key: "salesman", is_evo: true)
  end

  def coordinator_role
    @coordinator_role ||= Role.where(key: "coordinator", is_evo: true)
  end
end
