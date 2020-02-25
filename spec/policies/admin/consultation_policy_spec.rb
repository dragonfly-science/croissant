require "rails_helper"

RSpec.describe Admin::ConsultationPolicy, type: :policy do
  subject { Admin::ConsultationPolicy }

  context "with a superadmin level user" do
    let(:user) { FactoryBot.create(:user, role: "superadmin") }

    permissions :index? do
      it { expect(subject).to permit(user) }
    end

    permissions :edit? do
      it { expect(subject).to permit(user) }
    end

    permissions :update? do
      it { expect(subject).to permit(user) }
    end

    permissions :archive? do
      it { expect(subject).to permit(user) }
    end

    permissions :restore? do
      it { expect(subject).to permit(user) }
    end
  end

  context "with user that is an admin for any current consultation" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:consultation_user) { FactoryBot.create(:consultation_user, user: user, role: "admin") }

    permissions :index? do
      it { expect(subject).to permit(user) }
    end
  end

  context "with user that is an admin for the current consultation" do
    let(:user) { FactoryBot.create(:user) }
    let!(:consultation_user) { FactoryBot.create(:consultation_user, user: user, role: "admin") }

    permissions :edit? do
      it { expect(subject).to permit(user, consultation_user.consultation) }
    end

    permissions :update? do
      it { expect(subject).to permit(user, consultation_user.consultation) }
    end

    permissions :archive? do
      it { expect(subject).to permit(user, consultation_user.consultation) }
    end

    permissions :restore? do
      it { expect(subject).to permit(user, consultation_user.consultation) }
    end
  end

  context "with user that is not an admin for the current consultation" do
    let(:user) { FactoryBot.create(:user) }
    let!(:consultation) { FactoryBot.create(:consultation) }

    permissions :edit? do
      it { expect(subject).not_to permit(user, consultation) }
    end

    permissions :update? do
      it { expect(subject).not_to permit(user, consultation) }
    end

    permissions :archive? do
      it { expect(subject).not_to permit(user, consultation) }
    end

    permissions :restore? do
      it { expect(subject).not_to permit(user, consultation) }
    end
  end

  context "with an editor or viewer level user" do
    let(:user) { FactoryBot.create(:user) }

    permissions :index? do
      it { expect(subject).not_to permit(user) }
    end

    permissions :edit? do
      it { expect(subject).not_to permit(user) }
    end

    permissions :update? do
      it { expect(subject).not_to permit(user) }
    end

    permissions :archive? do
      it { expect(subject).not_to permit(user) }
    end

    permissions :restore? do
      it { expect(subject).not_to permit(user) }
    end
  end
end
