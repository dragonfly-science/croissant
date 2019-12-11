require "rails_helper"

RSpec.describe "Taxonomies", type: :request do
  let!(:consultation) { FactoryBot.create(:consultation) }
  let!(:taxonomy) { consultation.taxonomy }
  describe "GET /taxonomies/:id" do
    it "works" do
      get taxonomy_path(taxonomy)
      expect(response).to have_http_status(200)
    end
  end
end
