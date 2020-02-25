require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }

  it "is invalid without an email" do
    user = FactoryBot.build(:user, email: nil)
    expect(user).not_to be_valid
  end

  it "is invalid without a role" do
    user = FactoryBot.build(:user, role: nil)
    expect(user).not_to be_valid
  end

  describe "roles" do
    it "the viewer role is the default" do
      expect(user.viewer?).to eq true
      expect(user.role).to eq "viewer"
    end

    it "assigns the editor role" do
      expect(user.editor?).to eq false
      user.editor!
      expect(user.editor?).to eq true
      expect(user.role).to eq "editor"
    end

    it "assigns the admin role" do
      expect(user.admin?).to eq false
      user.admin!
      expect(user.admin?).to eq true
      expect(user.role).to eq "admin"
    end

    it "assigns the superadmin role" do
      expect(user.superadmin?).to eq false
      user.superadmin!
      expect(user.superadmin?).to eq true
      expect(user.role).to eq "superadmin"
    end
  end

  describe "#state_changes" do
    context "with a pending user" do
      let(:pending_user) { FactoryBot.create(:user, state: "pending") }

      it "can change state to active" do
        pending_user.approve!
        expect(pending_user.active?).to eq(true)
      end

      it "can change state to on_hold" do
        pending_user.suspend!
        expect(pending_user.on_hold?).to eq(true)
      end
    end

    context "with an active user" do
      let(:active_user) { FactoryBot.create(:user) }

      it "can change state to inactive" do
        active_user.suspend!
        expect(active_user.inactive?).to eq(true)
      end
    end

    context "with an inactive user" do
      let(:inactive_user) { FactoryBot.create(:user, state: "inactive") }

      it "can change state to active" do
        inactive_user.reactivate!
        expect(inactive_user.active?).to eq(true)
      end
    end

    context "with an on_hold user" do
      let(:on_hold_user) { FactoryBot.create(:user, state: "on_hold") }

      it "can change state to pending" do
        on_hold_user.reactivate!
        expect(on_hold_user.pending?).to eq(true)
      end
    end
  end

  describe "#consultation_admin?" do
    it "returns false if the user does not have an admin on any consultation" do
      expect(user.consultation_admin?).to eq(false)
    end

    it "returns true if the user has an admin role on any consultation" do
      FactoryBot.create(:consultation_user, user: user, role: "admin")
      expect(user.consultation_admin?).to eq(true)
    end
  end
end
