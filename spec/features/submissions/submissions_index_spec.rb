require "rails_helper"

RSpec.feature "Submissions index page", js: true do
  let(:user) { FactoryBot.create(:user, role: "superadmin") }
  let(:consultation) { FactoryBot.create(:consultation) }
  let!(:submissions) { FactoryBot.create_list(:submission, 3, consultation: consultation) }
  before { sign_in(user) }

  before do
    visit consultation_submissions_path(consultation)
  end

  it_behaves_like "an accessible page"

  it "displays a list of submissions" do
    expect(page).to have_link(submissions.first.name, href: submission_path(submissions.first))
    expect(page).to have_link(submissions.second.name, href: submission_path(submissions.second))
    expect(page).to have_link(submissions.third.name, href: submission_path(submissions.third))
  end

  it "displays the archive button for an archivable submission" do
    submissions.first.update!(state: "started")
    visit consultation_submissions_path(consultation)
    expect(page).to have_link("Archive", href: archive_submission_path(submissions.first))
  end

  it "does not show archived submissions by default" do
    submissions.first.update!(state: "archived")
    visit consultation_submissions_path(consultation)
    expect(page).not_to have_link(submissions.first.name, href: submission_path(submissions.first))
  end

  it "displays the restore button for an archived submission" do
    submissions.first.update!(state: "archived")
    visit consultation_submissions_path(consultation, filter: { include_archived: true })
    expect(page).to have_link("Restore", href: restore_submission_path(submissions.first))
  end
end
