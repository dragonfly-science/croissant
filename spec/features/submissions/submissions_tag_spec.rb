require "rails_helper"

RSpec.feature "Tagging a submission", js: true do
  let!(:consultation) { FactoryBot.create(:consultation, :with_taxonomy_tags) }
  let!(:submission) { FactoryBot.create(:submission, :ready_to_tag, consultation: consultation) }
  let!(:tags) { consultation.taxonomy.tags }

  before do
    visit consultation_submission_tag_path(consultation, submission)
  end

  it "renders selectable tags for the submission" do
    expect(page).to have_selector("button", text: tags.first.name)
  end

  it "renders the submissions text" do
  end

  describe "" do
  end
end
