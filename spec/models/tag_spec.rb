require "rails_helper"

RSpec.describe Tag, type: :model do
  let(:consultation) { FactoryBot.create(:consultation) }
  let(:taxonomy) { consultation.taxonomy }

  let(:consultation2) { FactoryBot.create(:consultation) }
  let(:taxonomy2) { consultation2.taxonomy }

  context "descendents" do
    let!(:grandparent_tag) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Livestock") }
    let!(:parent_tag) { FactoryBot.create(:tag, parent: grandparent_tag, taxonomy: taxonomy, name: "Cows") }
    let!(:child_tag) { FactoryBot.create(:tag, parent: parent_tag, taxonomy: taxonomy, name: "Good") }

    it "can have a parent" do
      expect(child_tag.parent).to eq(parent_tag)
      expect(parent_tag.parent).to eq(grandparent_tag)
    end

    it "can have children" do
      expect(parent_tag.children.to_a).to eq([child_tag])
      expect(grandparent_tag.children.to_a).to eq([parent_tag])
    end

    it "constructs a full name based on its parents" do
      expect(grandparent_tag.full_name).to eq("Livestock")
      expect(parent_tag.full_name).to eq("Livestock > Cows")
      expect(child_tag.full_name).to eq("Livestock > Cows > Good")
    end

    it "constructs a full number based on its parents" do
      expect(grandparent_tag.full_number).to eq("1")
      expect(parent_tag.full_number).to eq("1.1")
      expect(child_tag.full_number).to eq("1.1.1")
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

    it "can be the same as a tag with a different parent in the same taxonomy" do
      parent1 = FactoryBot.create(:tag, taxonomy: taxonomy, name: "Trees")
      parent2 = FactoryBot.create(:tag, taxonomy: taxonomy, name: "Cows")
      FactoryBot.create(:tag, taxonomy: taxonomy, name: "Good", parent: parent1)
      expect(Tag.new(taxonomy: taxonomy, name: "Good", parent: parent2)).to be_valid
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

  context "deleting" do
    let(:used_tag) { FactoryBot.create(:tag, taxonomy: taxonomy) }
    let(:unused_tag) { FactoryBot.create(:tag, taxonomy: taxonomy) }
    let(:tagged_submission) { FactoryBot.create(:submission, :ready_to_tag, consultation: taxonomy.consultation) }
    let(:untagged_submission) { FactoryBot.create(:submission, :ready_to_tag, consultation: taxonomy.consultation) }
    before do
      start_char = 0
      end_char = 3
      text = tagged_submission.text[start_char, end_char]
      tagged_submission.add_tag(tag: used_tag, start_char: start_char, end_char: end_char, text: text)
    end
    it "will not allow tags to be deleted if they have been used" do
      expect(used_tag.deletable?).to eq(false)
    end
    it "will raise an error if you try to delete a used tag" do
      expect { used_tag.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
    it "will allow tags to be deleted if they have not been used" do
      expect(unused_tag.deletable?).to eq(true)
    end
    it "will be fine with it if you delete an unused tag" do
      expect { unused_tag.destroy! }.not_to raise_error
    end
  end

  context "numbers" do
    let!(:tag1) { FactoryBot.create(:tag, taxonomy: taxonomy) }
    let!(:tag11) { FactoryBot.create(:tag, parent: tag1, taxonomy: taxonomy) }
    let!(:tag2) { FactoryBot.create(:tag, taxonomy: taxonomy) }
    let!(:tag21) { FactoryBot.create(:tag, parent: tag2, taxonomy: taxonomy) }
    let!(:tag12) { FactoryBot.create(:tag, parent: tag1, taxonomy: taxonomy) }
    let!(:tag22) { FactoryBot.create(:tag, parent: tag2, taxonomy: taxonomy) }
    let!(:tag111) { FactoryBot.create(:tag, parent: tag11, taxonomy: taxonomy) }
    let!(:tag221) { FactoryBot.create(:tag, parent: tag22, taxonomy: taxonomy) }

    it "creates full numbers" do
      expect(tag1.full_number).to eq("1")
      expect(tag11.full_number).to eq("1.1")
      expect(tag12.full_number).to eq("1.2")
      expect(tag2.full_number).to eq("2")
      expect(tag21.full_number).to eq("2.1")
      expect(tag22.full_number).to eq("2.2")
    end
    it "orders by full numbers" do
      expect(taxonomy.tags.number_order.to_a).to eq(
        [tag1, tag11, tag111, tag12, tag2, tag21, tag22, tag221]
      )
    end
  end
end
