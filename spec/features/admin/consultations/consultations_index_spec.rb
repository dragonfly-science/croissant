require "rails_helper"

RSpec.feature "Viewing a list of consultations", js: true do
  let!(:consultation1) { FactoryBot.create(:consultation) }
  let!(:consultation2) { FactoryBot.create(:consultation) }
  let!(:consultation3) { FactoryBot.create(:consultation) }
  let!(:archived_consultation) { FactoryBot.create(:consultation, state: "archived") }
  let!(:superadmin_user) { FactoryBot.create(:user, role: "superadmin") }

  before { sign_in(superadmin_user) }

  before do
    visit admin_consultations_path
  end

  it "renders a list of consultations" do
    expect(page).to have_content(consultation1.name)
    expect(page).to have_content(consultation2.name)
    expect(page).to have_content(consultation3.name)
    expect(page).to have_content(archived_consultation.name)
  end

  it "renders archive buttons for active consultations" do
    expect(page).to have_link("Archive", href: admin_archive_consultation_path(consultation1))
  end

  it "renders a restore button for an archived consultation" do
    expect(page).to have_link("Restore", href: admin_restore_consultation_path(archived_consultation))
  end

  it "archives a consultation when the archive button is clicked" do
    find(:css, "a[href='#{admin_archive_consultation_path(consultation1)}']").click
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_link("Restore", href: admin_restore_consultation_path(consultation1))
  end

  it "restores a consultation when the restore button is clicked" do
    find(:css, "a[href='#{admin_restore_consultation_path(archived_consultation)}']").click
    expect(page).to have_link("Archive", href: admin_archive_consultation_path(archived_consultation))
  end
end
