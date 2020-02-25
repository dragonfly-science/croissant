require "rails_helper"

RSpec.describe Admin::UserPolicy, type: :policy do
  subject { Admin::UserPolicy }

  context "with an admin or superadmin level user" do
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

    permissions :search? do
      it { expect(subject).to permit(user) }
    end

    permissions :approve? do
      it { expect(subject).to permit(user) }
    end

    permissions :suspend? do
      it { expect(subject).to permit(user) }
    end

    permissions :reactivate? do
      it { expect(subject).to permit(user) }
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

    permissions :search? do
      it { expect(subject).not_to permit(user) }
    end

    permissions :approve? do
      it { expect(subject).not_to permit(user) }
    end

    permissions :suspend? do
      it { expect(subject).not_to permit(user) }
    end

    permissions :reactivate? do
      it { expect(subject).not_to permit(user) }
    end
  end

  context "search" do
    context "with a user with an admin role for at least one consultation" do
      let(:consultation_user) { FactoryBot.create(:consultation_user, role: "admin") }

      permissions :search? do
        it { expect(subject).to permit(consultation_user.user) }
      end
    end
  end
end
