require "rails_helper"

RSpec.describe TaxonomyExporter do
  let(:consultation) { FactoryBot.create(:consultation, name: "With a Space") }
  let(:taxonomy) { consultation.taxonomy }
  let!(:tag1) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Bears", description: "Ahh!") }
  let!(:tag11) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Polar", parent: tag1) }
  let!(:tag2) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Wolves") }
  let!(:tag12) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Grizzly", parent: tag1) }
  let!(:tag111) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Friendly", parent: tag11) }
  let!(:tag21) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Arctic", parent: tag2) }
  let!(:tag112) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Mean", parent: tag11) }

  subject { TaxonomyExporter.new(taxonomy) }

  it "creates a CSV with tag_id, number, name, and description columns" do
    csv = subject.export
    expect(csv).to start_with("tag_id,number,name,description\n")
  end

  it "includes all tags in number order" do
    tags_in_order = [tag1, tag11, tag111, tag112, tag12, tag2, tag21]
    expect(subject.items.to_a).to eq(tags_in_order)
    expect(subject.export.lines.count).to eq(tags_in_order.count + 1)
  end

  it "includes the full number, name and ID for each tag" do
    csv = subject.export
    expect(csv.lines[1]).to eq("#{tag1.id},1,Bears,Ahh!\n")
    expect(csv.lines[2]).to eq("#{tag11.id},1.1,Polar,\"\"\n")
    expect(csv.lines[3]).to eq("#{tag111.id},1.1.1,Friendly,\"\"\n")
    expect(csv.lines[4]).to eq("#{tag112.id},1.1.2,Mean,\"\"\n")
  end

  it "includes the date and consultation name in the filename" do
    expect(subject.filename).to eq("#{Time.zone.today.iso8601}-with-a-space-taxonomy.csv")
  end
end
