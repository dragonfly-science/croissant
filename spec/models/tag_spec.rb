require "rails_helper"

RSpec.describe Tag, type: :model do
  let(:consultation) { FactoryBot.create(:consultation) }
  let(:taxonomy) { consultation.taxonomy }

  let(:consultation2) { FactoryBot.create(:consultation) }
  let(:taxonomy2) { consultation2.taxonomy }

  context "descendents" do
    let!(:parent_tag) { FactoryBot.create(:tag, taxonomy: taxonomy) }
    let!(:child_tag) { FactoryBot.create(:tag, parent: parent_tag, taxonomy: taxonomy) }

    it "can have a parent" do
      expect(child_tag.parent).to eq(parent_tag)
    end

    it "can have children" do
      expect(parent_tag.children.first).to eq(child_tag)
    end
  end

  it "must have a taxonomy" do
    expect(Tag.new(taxonomy: nil)).not_to be_valid
  end

  context "name" do
    it "must be present" do
      expect(Tag.new(taxonomy: taxonomy, name: "")).not_to be_valid
    end

    it "must be unique within a taxonomy" do
      FactoryBot.create(:tag, taxonomy: taxonomy, name: "Trees")
      expect(Tag.new(taxonomy: taxonomy, name: "Trees")).not_to be_valid
    end

    it "can be the same as a tag in another taxonomy" do
      FactoryBot.create(:tag, taxonomy: taxonomy2, name: "Trees")
      expect(Tag.new(taxonomy: taxonomy, name: "Trees")).to be_valid
    end
  end

  context "parent_level scope" do
    it "returns all scopes with a parent id of nil" do
      parent_tag_1 = FactoryBot.create(:tag, taxonomy: taxonomy)
      parent_tag_2 = FactoryBot.create(:tag, taxonomy: taxonomy)
      child_tag_1 = FactoryBot.create(:tag, taxonomy: taxonomy, parent: parent_tag_1)
      expect(described_class.top_level).to include(parent_tag_1, parent_tag_2)
      expect(described_class.top_level).to_not include(child_tag_1)
    end
  end
end
