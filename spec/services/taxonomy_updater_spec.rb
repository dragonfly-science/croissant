require "rails_helper"

RSpec.describe TaxonomyUpdater do
  let(:filename) { "2020-01-30-test-taxonomy.csv" }
  let(:filetype) { "text/csv" }
  let(:file) { Rack::Test::UploadedFile.new("spec/support/example_files/#{filename}", filetype) }
  let(:taxonomy) { FactoryBot.create(:consultation).taxonomy }
  subject { TaxonomyUpdater.new(file, taxonomy) }

  it "is valid" do
    expect(subject.valid?).to eq(true)
  end

  it "returns an empty list of validity errors" do
    expect(subject.validity_errors).to eq([])
  end

  context "with existing tags" do
    let(:tag) { FactoryBot.create(:tag, taxonomy: taxonomy, number: "1", name: "Living things") }
    let(:csv) { "tag_id,number,name,description\n#{updater_row}" }
    let(:updater_row) { "#{tag.id},1,Animals,Animals not elsewhere specified" }

    before do
      expect(subject).to receive(:csv).at_least(:once) { CSV.parse(csv, headers: true) }
    end

    it "updates tags that have an ID within the taxonomy in the CSV but have changed" do
      subject.update_tags!
      expect(tag.reload.name).to eq("Animals")
      expect(tag.reload.description).to eq("Animals not elsewhere specified")
      expect(tag.reload.number).to eq("1")
    end
    it "does not update tags that are not in the taxonomy" do
      other_taxonomy = FactoryBot.create(:consultation).taxonomy
      tag = FactoryBot.create(:tag, taxonomy: other_taxonomy, name: "Living things")
      subject.update_tags!
      expect(tag.reload.name).to eq("Living things")
    end
  end

  it "performs no action on tags that are identical in the CSV" do
    # same as first line of test-taxonomy.csv
    tag = FactoryBot.create(:tag, taxonomy: taxonomy, number: "1", name: "animals",
                                  description: "Top-level tag for animals not described elsewhere")

    subject.update_tags!
    expect(subject.unchanged_tags.first.tag).to eq(tag)
  end

  it "creates new tags" do
    subject.update_tags!
    animal_tag = taxonomy.tags.find_by(full_number: "1", name: "animals")
    expect(subject.created_tags).to include(TagResult.new(:created, animal_tag))
  end

  it "infers the appropriate parent from the numbering" do
    subject.update_tags!
    animal_tag = taxonomy.tags.find_by(full_number: "1", name: "animals")
    bear_tag = taxonomy.tags.find_by(full_number: "1.1", name: "bears")
    panda_tag = taxonomy.tags.find_by(full_number: "1.1.1", name: "panda")
    giant_panda_tag = taxonomy.tags.find_by(full_number: "1.1.1.1", name: "giant")
    expect(animal_tag.parent).to eq(nil)
    expect(animal_tag.number).to eq("1")
    expect(bear_tag.parent).to eq(animal_tag)
    expect(bear_tag.number).to eq("1")
    expect(panda_tag.parent).to eq(bear_tag)
    expect(panda_tag.number).to eq("1")
    expect(giant_panda_tag.parent).to eq(panda_tag)
    expect(giant_panda_tag.number).to eq("1")
  end

  it "does not delete tags that are missing from the file" do
    tag = FactoryBot.create(:tag, taxonomy: taxonomy, number: "9", name: "friends")
    subject.update_tags!
    expect(taxonomy.tags).to include(tag)
  end

  context "with a file with the wrong headers" do
    let(:filename) { "wrong-headers-taxonomy.csv" }
    let(:filetype) { "text/csv" }

    it "is not valid" do
      expect(subject.valid?).to eq(false)
    end

    it "does not proceed with updating tags" do
      expect(subject.update_tags!).to eq(false)
    end

    it "has a list of validity errors" do
      expect(subject.validity_errors).to eq(["Wrong headers"])
    end
  end

  context "with a file of the wrong format" do
    let(:filename) { "single-page.pdf" }
    let(:filetype) { "application/pdf" }

    it "is not valid" do
      expect(subject.valid?).to eq(false)
    end

    it "does not proceed with updating tags" do
      expect(subject.update_tags!).to eq(false)
    end

    it "has a list of validity errors" do
      expect(subject.validity_errors).to eq(["Wrong format"])
    end
  end

  context "with a file that is empty" do
    let(:filename) { "empty-taxonomy.csv" }
    let(:filetype) { "text/csv" }

    it "is not valid" do
      expect(subject.valid?).to eq(false)
    end

    it "does not proceed with updating tags" do
      expect(subject.update_tags!).to eq(false)
    end

    it "has a list of validity errors" do
      expect(subject.validity_errors).to eq(["File empty"])
    end
  end
end
