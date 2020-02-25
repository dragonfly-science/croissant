require "rails_helper"

RSpec.describe UserConsultationsService do
  let!(:superadmin) { FactoryBot.create(:user, role: "superadmin") }
  let!(:editor) { FactoryBot.create(:user, role: "editor") }
  let!(:consultation1) { FactoryBot.create(:consultation, name: "banjo") }
  let!(:consultation2) { FactoryBot.create(:consultation, name: "drum") }
  let!(:consultation3) { FactoryBot.create(:consultation, name: "big flute") }

  describe "#self.consultations" do
    it "returns all active consultations in alphabetical order for a superadmin user" do
      consultations = UserConsultationsService.consultations(superadmin)
      expect(consultations.to_a).to eq([consultation1, consultation3, consultation2])
    end

    it "returns all active consultations a user has access to for a non superadmin user" do
      FactoryBot.create(:consultation_user, consultation: consultation1, user: editor)
      FactoryBot.create(:consultation_user, consultation: consultation3, user: editor)
      consultations = UserConsultationsService.consultations(editor)
      expect(consultations.to_a).to eq([consultation1, consultation3])
      expect(consultations.to_a).not_to include(consultation2)
    end
  end

  describe "#self.admin_consultations" do
    it "returns all consultations in alphabetical order by default" do
      consultations = UserConsultationsService.admin_consultations(superadmin, nil)
      expect(consultations.to_a).to eq([consultation1, consultation3, consultation2])
    end

    it "returns all consultations in the provided order for a superadmin" do
      consultations = UserConsultationsService.admin_consultations(superadmin, "id DESC")
      expect(consultations.to_a).to eq([consultation3, consultation2, consultation1])
    end

    it "returns all consultations for which the user is an admin in the provided order for non super admin users" do
      FactoryBot.create(:consultation_user, consultation: consultation2, user: editor, role: "admin")
      FactoryBot.create(:consultation_user, consultation: consultation3, user: editor, role: "admin")
      consultations = UserConsultationsService.admin_consultations(editor, "id DESC")
      expect(consultations.to_a).to eq([consultation3, consultation2])
      expect(consultations.to_a).not_to include(consultation1)
    end
  end
end
