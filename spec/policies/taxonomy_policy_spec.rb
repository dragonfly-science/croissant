require "rails_helper"

RSpec.describe TaxonomyPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:taxonomy) { FactoryBot.create(:taxonomy) }
  let!(:consultation_user) do
    FactoryBot.create(:consultation_user, user: user, consultation: taxonomy.consultation)
  end
  subject { TaxonomyPolicy }

  permissions :show? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, taxonomy)
    end

    it "permits any consultation user with access" do
      expect(subject).to permit(user, taxonomy)
    end
  end

  permissions :upload? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "does not permit consultation users with the viewer role" do
      expect(subject).not_to permit(user, taxonomy)
    end

    it "does not permit users with no access to the consultation" do
      consultation_user.destroy
      expect(subject).not_to permit(user, taxonomy)
    end

    it "permits any consultation user with a role higher than viewer" do
      consultation_user.update!(role: "editor")
      expect(subject).to permit(user, taxonomy)
    end
  end
end
