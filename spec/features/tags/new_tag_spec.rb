require "rails_helper"

RSpec.feature "Creating a new tag", js: true do
  let!(:consultation) { FactoryBot.create(:consultation) }

  context "navigating" do
    it "allows creating a new tag from the consultation" do
      visit root_path
      click_link(consultation.name)
      click_link("Taxonomy")
      fill_in("Name", with: "Trees")
      click_button("✔")
      expect(page).to have_selector("button", text: "Trees")
    end
  end
end
