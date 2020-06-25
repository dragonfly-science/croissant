require "rails_helper"

RSpec.describe SubmissionTagPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:submission_tag) { FactoryBot.create(:submission_tag, tagger: user) }
  let(:consultation_user) do
    FactoryBot.create(:consultation_user, user: user,
                                          consultation: submission_tag.taggable.consultation)
  end
  subject { SubmissionTagPolicy }

  permissions :create? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, submission_tag)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission_tag)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, submission_tag)
    end
  end

  permissions :destroy? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, submission_tag)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, submission_tag)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, submission_tag)
    end
  end
end
