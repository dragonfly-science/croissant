require "rails_helper"

RSpec.describe TagNumberer do
  let(:consultation) { FactoryBot.create(:consultation) }
  let(:taxonomy) { consultation.taxonomy }

  let!(:grandparent_tag1) do
    FactoryBot.create(:tag, taxonomy: taxonomy,
                            name: "Livestock",
                            number: nil)
  end
  let!(:parent_tag1) do
    FactoryBot.create(:tag, parent: grandparent_tag1,
                            taxonomy: taxonomy,
                            name: "Cows",
                            number: nil)
  end
  let!(:child_tag1) do
    FactoryBot.create(:tag, parent: parent_tag1,
                            taxonomy: taxonomy,
                            name: "Good",
                            number: nil)
  end
  let!(:child_tag2) do
    FactoryBot.create(:tag, parent: parent_tag1,
                            taxonomy: taxonomy,
                            name: "Bad",
                            number: nil)
  end

  let!(:parent_tag2) do
    FactoryBot.create(:tag, parent: grandparent_tag1,
                            taxonomy: taxonomy,
                            name: "Sheep",
                            number: nil)
  end

  let!(:child_tag3) do
    FactoryBot.create(:tag, parent: parent_tag2,
                            taxonomy: taxonomy,
                            name: "Good",
                            number: nil)
  end
  let!(:child_tag4) do
    FactoryBot.create(:tag, parent: parent_tag2,
                            taxonomy: taxonomy,
                            name: "Bad",
                            number: nil)
  end

  let!(:grandparent_tag2) do
    FactoryBot.create(:tag, taxonomy: taxonomy,
                            name: "Vehicles", number: nil)
  end
  let!(:parent_tag3) do
    FactoryBot.create(:tag, parent: grandparent_tag2,
                            taxonomy: taxonomy,
                            name: "EVs",
                            number: nil)
  end
  let!(:child_tag5) do
    FactoryBot.create(:tag, parent: parent_tag3,
                            taxonomy: taxonomy,
                            name: "Good",
                            number: nil)
  end
  let!(:child_tag6) do
    FactoryBot.create(:tag, parent: parent_tag3,
                            taxonomy: taxonomy,
                            name: "Bad",
                            number: nil)
  end
  let!(:parent_tag4) do
    FactoryBot.create(:tag, parent: grandparent_tag2,
                            taxonomy: taxonomy,
                            name: "ICEs",
                            number: nil)
  end
  let!(:child_tag7) do
    FactoryBot.create(:tag, parent: parent_tag4,
                            taxonomy: taxonomy,
                            name: "Good",
                            number: nil)
  end
  let!(:child_tag8) do
    FactoryBot.create(:tag, parent: parent_tag4,
                            taxonomy: taxonomy,
                            name: "Bad",
                            number: nil)
  end

  it "numbers top-level tags correctly" do
    TagNumberer.call(taxonomy)
    expect(grandparent_tag1.reload.number).to eq("1")
    expect(grandparent_tag2.reload.number).to eq("2")
  end

  it "numbers second-level tags correctly" do
    TagNumberer.call(taxonomy)
    expect(parent_tag1.reload.number).to eq("1")
    expect(parent_tag2.reload.number).to eq("2")
    expect(parent_tag3.reload.number).to eq("1")
    expect(parent_tag4.reload.number).to eq("2")
  end

  it "numbers third-level tags correctly" do
    TagNumberer.call(taxonomy)
    expect(child_tag1.reload.number).to eq("1")
    expect(child_tag2.reload.number).to eq("2")
    expect(child_tag3.reload.number).to eq("1")
    expect(child_tag4.reload.number).to eq("2")
  end

  it "generates a new number for top level tags" do
    TagNumberer.call(taxonomy)
    expect(TagNumberer.new_number_for(taxonomy.tags.top_level)).to eq(3)
  end

  it "generates a new number for child tags" do
    TagNumberer.call(taxonomy)
    expect(TagNumberer.new_number_for(parent_tag1.children)).to eq(3)
  end

  it "generates a number that hasn't been taken if a number has been taken" do
    child_tag2.update(number: "3")
    expect(TagNumberer.new_number_for(parent_tag1.children)).to eq(4)
  end

  it "does not overwrite existing numbers" do
    child_tag2.update(number: "99")
    TagNumberer.call(taxonomy)
    expect(child_tag2.number).to eq("99")
  end
end
