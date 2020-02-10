require "rails_helper"

RSpec.feature "Viewing a list of users", js: true do
  let!(:viewer_user) { FactoryBot.create(:user) }
  let!(:superadmin_user) { FactoryBot.create(:user, role: "superadmin") }
  let!(:unapproved_user) { FactoryBot.create(:user, state: "pending") }
  let!(:suspended_user) { FactoryBot.create(:user, state: "inactive") }

  before { sign_in(superadmin_user) }

  before do
    visit admin_users_path
  end

  it "renders a list of the users" do
    expect(page).to have_content(viewer_user.email)
    expect(page).to have_content(superadmin_user.email)
    expect(page).to have_content(unapproved_user.email)
    expect(page).to have_content(suspended_user.email)
  end

  it "renders a link to edit individual users" do
    expect(page).to have_link("edit", href: edit_admin_user_path(viewer_user))
  end

  it "renders approve and suspend buttons for a pending user" do
    expect(page).to have_link("approve", href: admin_approve_user_path(unapproved_user))
    expect(page).to have_link("suspend", href: admin_suspend_user_path(unapproved_user))
  end

  it "renders a suspend button for an active user" do
    expect(page).to have_link("suspend", href: admin_suspend_user_path(superadmin_user))
  end

  it "renders a reactivate button for an inactive user" do
    expect(page).to have_link("reactivate", href: admin_reactivate_user_path(suspended_user))
  end
end
