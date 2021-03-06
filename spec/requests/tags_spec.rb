require "rails_helper"

RSpec.describe "Tags", type: :request do
  let(:user) { FactoryBot.create(:user, role: "superadmin") }
  before do
    sign_in(user)
  end
  let!(:consultation) { FactoryBot.create(:consultation) }
  let!(:taxonomy) { consultation.taxonomy }
  describe "POST /taxonomies/:id/tags/create" do
    it "works" do
      post taxonomy_tags_path(taxonomy_id: taxonomy.id, tag: { name: "something" })
      expect(response).to have_http_status(302)
    end
  end
  describe "POST /taxonomies/:id/tags/destroy" do
    it "works" do
      tag = FactoryBot.create(:tag, taxonomy: taxonomy)
      delete taxonomy_tag_path(taxonomy_id: taxonomy.id, id: tag.id)
      expect(response).to have_http_status(302)
    end
    it "errors if the taxonomy and tag don't match" do
      other_taxonomy = FactoryBot.create(:consultation).taxonomy
      tag = FactoryBot.create(:tag, taxonomy: taxonomy)
      expect do
        delete taxonomy_tag_path(taxonomy_id: other_taxonomy, id: tag.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
