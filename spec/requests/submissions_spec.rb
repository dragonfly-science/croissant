require "rails_helper"

RSpec.describe "Submissions", type: :request do
  let!(:consultation) { FactoryBot.create(:consultation) }
  describe "GET /submissions" do
    it "works! (now write some real specs)" do
      get consultation_submissions_path(consultation)
      expect(response).to have_http_status(200)
    end
  end
end
