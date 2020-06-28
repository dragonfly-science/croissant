require "rails_helper"

RSpec.feature "Tagging a submission", js: true do
  let(:user) { FactoryBot.create(:user, role: "superadmin") }
  let!(:consultation) { FactoryBot.create(:consultation, :with_taxonomy_tags) }
  let!(:submission) do
    FactoryBot.create_list(:submission, 2, :ready_to_tag, consultation: consultation,
                                                          text: "cows dogs and sheep in the ocean riding waves")
  end
  let!(:tags) { consultation.taxonomy.tags }

  before { sign_in(user) }

  before do
    visit consultation_submission_tag_path(consultation, submission)
  end

  it "renders" do
    expect(page).to have_selector("form[data-testid=submission-navigation]")
  end

  it "has navigation buttons disabled where no navigation is possible" do
    expect(page).to have_selector("a[data-testid=nav-first].disabled")
    expect(page).to have_selector("a[data-testid=nav-prev].disabled")
    expect(page).not_to have_selector("a[data-testid=nav-next].disabled")
    expect(page).not_to have_selector("a[data-testid=nav-last].disabled")
    find("a[data-testid=nav-next]").click
    expect(page).not_to have_selector("a[data-testid=nav-first].disabled")
    expect(page).not_to have_selector("a[data-testid=nav-prev].disabled")
    expect(page).to have_selector("a[data-testid=nav-next].disabled")
    expect(page).to have_selector("a[data-testid=nav-last].disabled")
    find("a[data-testid=nav-prev]").click
    expect(page).to have_selector("a[data-testid=nav-first].disabled")
    expect(page).to have_selector("a[data-testid=nav-prev].disabled")
    expect(page).not_to have_selector("a[data-testid=nav-next].disabled")
    expect(page).not_to have_selector("a[data-testid=nav-last].disabled")
    find("a[data-testid=nav-last]").click
    expect(page).not_to have_selector("a[data-testid=nav-first].disabled")
    expect(page).not_to have_selector("a[data-testid=nav-prev].disabled")
    expect(page).to have_selector("a[data-testid=nav-next].disabled")
    expect(page).to have_selector("a[data-testid=nav-last].disabled")
    find("a[data-testid=nav-first]").click
    expect(page).to have_selector("a[data-testid=nav-first].disabled")
    expect(page).to have_selector("a[data-testid=nav-prev].disabled")
    expect(page).not_to have_selector("a[data-testid=nav-next].disabled")
    expect(page).not_to have_selector("a[data-testid=nav-last].disabled")
  end
end
