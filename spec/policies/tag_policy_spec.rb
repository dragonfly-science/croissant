require "rails_helper"

RSpec.describe TagPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:taxonomy) { FactoryBot.create(:taxonomy) }
  let(:tag) { FactoryBot.create(:tag, taxonomy: taxonomy) }
  let(:consultation_user) do
    FactoryBot.create(:consultation_user, user: user, consultation: taxonomy.consultation)
  end

  subject { TagPolicy }

  permissions :create? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, tag)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, tag)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, tag)
    end
  end

  permissions :destroy? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, tag)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, tag)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, tag)
    end
  end
end
