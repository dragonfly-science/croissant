require "rails_helper"

RSpec.describe Admin::ConsultationUserPolicy, type: :policy do
  subject { Admin::ConsultationUserPolicy }

  context "with a superadmin level user" do
    let(:user) { FactoryBot.create(:user, role: "superadmin") }

    permissions :destroy? do
      it { expect(subject).to permit(user) }
    end
  end

  context "with user that is an admin for the consultation attributed to the record" do
    let(:user) { FactoryBot.create(:user) }
    let!(:consultation_user) { FactoryBot.create(:consultation_user, user: user, role: "admin") }

    permissions :destroy? do
      it { expect(subject).to permit(user, consultation_user) }
    end
  end

  context "with user that is not an admin for the consultation attributed to the record" do
    let(:user) { FactoryBot.create(:user) }
    let!(:consultation_user) { FactoryBot.create(:consultation_user) }

    permissions :destroy? do
      it { expect(subject).not_to permit(user, consultation_user) }
    end
  end
end
