require "rails_helper"

RSpec.feature "Consultations new page", js: true do
  let(:user) { FactoryBot.create(:user, role: "superadmin") }
  before do
    sign_in(user)
    visit new_consultation_path
  end

  it_behaves_like "an accessible page"

  it "renders the correct consultation form fields" do
    expect(page).to have_selector("#consultation_name")
    expect(page).to have_selector("#consultation_consultation_type")
  end

  context "when submitting with invalid form data" do
    before { click_button "Create Consultation" }

    it "renders a flash error" do
      expect(page).to have_content I18n.t("consultation.create.failure")
    end

    it "renders errors about the invalid form fields" do
      expect(page).to have_content("Name can't be blank")
    end
  end
end
