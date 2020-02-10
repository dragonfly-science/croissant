require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  subject { UserPolicy }

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
  end
end
