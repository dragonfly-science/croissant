require "rails_helper"

RSpec.feature "Creating a new tag", js: true do
  let(:user) { FactoryBot.create(:user) }
  let!(:consultation) { FactoryBot.create(:consultation) }
  before { sign_in(user) }

  context "navigating" do
    it "allows creating a new tag from the consultation" do
      visit root_path
      click_link(consultation.name)
      within("#consultation-nav") do
        click_link("Taxonomy")
      end
      fill_in("Name", with: "Trees")
      click_button("✔")
      expect(page).to have_selector("button", text: "Trees")
    end
  end
end
