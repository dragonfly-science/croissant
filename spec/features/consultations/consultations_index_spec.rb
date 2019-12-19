require "rails_helper"

RSpec.feature "Consultations index page", js: true do
  let!(:consultations) { FactoryBot.create_list(:consultation, 3) }

  before do
    visit consultations_path
  end

  it_behaves_like "an accessible page"

  it "renders consultation names and types" do
    expect(page).to have_content(consultations.first.name)
    expect(page).to have_content(consultations.first.consultation_type)
  end

  it "renders links to each consultations show page" do
    expect(page).to have_link(consultations.first.name)
  end

  it "clicking a consultation link takes you to the submissions page" do
    find_link(consultations.first.name).click
    expect(page).to have_css("#consultation-nav .navbar-brand", text: consultations.first.name)
  end
end
