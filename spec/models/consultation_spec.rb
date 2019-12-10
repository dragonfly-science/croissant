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
end
