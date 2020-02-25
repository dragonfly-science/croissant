require "rails_helper"

RSpec.feature "Viewing an exisiting taxonomy", js: true do
  let(:user) { FactoryBot.create(:user, role: "superadmin") }
  let(:consultation) { FactoryBot.create(:consultation) }
  before { sign_in(user) }

  before do
    visit taxonomy_path(consultation.taxonomy)
  end

  it_behaves_like "an accessible page"
end
