require "rails_helper"

RSpec.describe Consultation, type: :model do
  subject { FactoryBot.build(:consultation) }

  it { is_expected.to have_attribute :name }
  it { is_expected.to have_attribute :consultation_type }

  it "is invalid without a name" do
    subject.name = ""
    expect(subject).not_to be_valid
  end

  it "is invalid without a consultation_type" do
    subject.consultation_type = ""
    expect(subject).not_to be_valid
  end

  it "is invalid with a consultation_type not included in the enum" do
    expect { subject.consultation_type = "hotdog" }.to raise_error(ArgumentError)
  end

  it "creates a new taxonomy when it is created" do
    expect(subject.taxonomy).to be_an_instance_of(Taxonomy)
  end

  context "alphabetical_order scope" do
    it "returns all consultations ordered alphabetically" do
      consultation2 = FactoryBot.create(:consultation, name: "Be a banana")
      consultation1 = FactoryBot.create(:consultation, name: "A hotdog")
      consultation3 = FactoryBot.create(:consultation, name: "The only apple")

      expect(Consultation.alphabetical_order.to_a).to eq([consultation1, consultation2, consultation3])
    end
  end
end
