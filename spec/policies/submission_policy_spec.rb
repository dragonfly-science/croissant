require "rails_helper"

RSpec.describe SubmissionPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let!(:consultation_user) { FactoryBot.create(:consultation_user, user: user) }
  let!(:submission) { FactoryBot.create(:submission, consultation: consultation_user.consultation) }
  subject { SubmissionPolicy }

  permissions :create? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, submission)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, submission)
    end
  end

  permissions :show? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission)
    end

    it "permits any consultation user with access" do
      expect(subject).to permit(user, submission)
    end
  end

  permissions :destroy? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, submission)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, submission)
    end
  end

  permissions :tag? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, submission)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, submission)
    end
  end

  permissions :edit? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, submission)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, submission)
    end
  end

  permissions :update? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, submission)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, submission)
    end
  end

  permissions :mark_process? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, submission)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, submission)
    end
  end

  permissions :mark_complete? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, submission)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, submission)
    end
  end

  permissions :mark_reject? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, submission)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, submission)
    end
  end

  permissions :mark_archived? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer or editor role" do
      expect(subject).not_to permit(user, submission)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission)
    end

    it "permits consultation admins" do
      consultation_user.update!(role: "admin")
      expect(subject).to permit(user, submission)
    end
  end

  permissions :mark_restored? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer or editor role" do
      expect(subject).not_to permit(user, submission)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission)
    end

    it "permits consultation admins" do
      consultation_user.update!(role: "admin")
      expect(subject).to permit(user, submission)
    end
  end
end
