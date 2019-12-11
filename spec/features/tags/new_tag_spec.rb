require "rails_helper"

RSpec.feature "Creating a new tag", js: true do
  let(:consultation) { FactoryBot.create(:consultation) }

  context "navigating" do
    it "allows creating a new tag from the consultation" do
      visit consultation_path(consultation)
      click_link("Taxonomy")
      click_link("New tag")
      fill_in("Name", with: "Trees")
      click_button("Create Tag")
      expect(page).to have_selector("li", text: "Trees")
    end
  end

  context "the new tag page" do
    before do
      visit new_taxonomy_tag_path(consultation.taxonomy)
    end

    it_behaves_like "an accessible page"
  end
end
