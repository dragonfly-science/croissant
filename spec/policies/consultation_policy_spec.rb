require "rails_helper"

RSpec.describe ConsultationPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  subject { ConsultationPolicy }

  permissions :index? do
    it "permits any level of user" do
      expect(subject).to permit(user)
    end
  end

  permissions :show? do
    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end

    it "permits users with access to the current consultation" do
      consultation_user = FactoryBot.create(:consultation_user, user: user)
      expect(subject).to permit(user, consultation_user.consultation)
    end
  end

  permissions :new? do
    it "does not permit viewer level users" do
      expect(subject).not_to permit(user)
    end

    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end
  end

  permissions :create? do
    it "does not permit viewer level users" do
      expect(subject).not_to permit(user)
    end

    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user)
    end
  end

  permissions :export? do
    let(:consultation) { FactoryBot.create(:consultation_user).consultation }

    it "does not permit viewer level users" do
      expect(subject).not_to permit(user, consultation)
    end

    it "does not permit users who are not assigned to the consultation" do
      user.update!(role: "admin")
      expect(subject).not_to permit(user, consultation)
    end

    it "does permit users who are assigned to the consultation" do
      user.update!(role: "admin")
      permitted_consultation = FactoryBot.create(:consultation_user, user: user).consultation
      expect(subject).to permit(user, permitted_consultation)
    end

    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user, consultation)
    end
  end

  permissions :consultation_access? do
    let(:consultation) { FactoryBot.create(:consultation_user).consultation }

    it "does not permit users who are not assigned to the consultation" do
      user.update!(role: "admin")
      expect(subject).not_to permit(user, consultation)
    end

    it "does permit users who are assigned to the consultation" do
      user.update!(role: "admin")
      permitted_consultation = FactoryBot.create(:consultation_user, user: user).consultation
      expect(subject).to permit(user, permitted_consultation)
    end

    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user, consultation)
    end
  end

  permissions :consultation_write_access? do
    let(:consultation) { FactoryBot.create(:consultation_user).consultation }

    it "does not permit users who are not assigned to the consultation" do
      expect(subject).not_to permit(user, consultation)
    end

    it "does not permit users who are assigned to the consultation with a viewer role" do
      permitted_consultation = FactoryBot.create(:consultation_user, user: user).consultation
      expect(subject).not_to permit(user, permitted_consultation)
    end

    it "does permit users who are assigned to the consultation with a role greater than viewer" do
      permitted_consultation = FactoryBot.create(:consultation_user,
                                                 user: user,
                                                 role: "admin").consultation
      expect(subject).to permit(user, permitted_consultation)
    end

    it "permits superadmin users" do
      user.update!(role: "superadmin")
      expect(subject).to permit(user, consultation)
    end
  end
end
