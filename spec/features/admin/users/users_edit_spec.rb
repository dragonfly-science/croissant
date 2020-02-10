require "rails_helper"

RSpec.feature "Editing a user", js: true do
  let!(:viewer_user) { FactoryBot.create(:user) }
  let!(:superadmin_user) { FactoryBot.create(:user, role: "superadmin") }

  before { sign_in(superadmin_user) }

  before do
    visit edit_admin_user_path(viewer_user)
  end

  it "renders the users role for editing" do
    expect(page).to have_select("user[role]", selected: "viewer",
                                              options: %w[viewer editor admin superadmin])
  end
end
