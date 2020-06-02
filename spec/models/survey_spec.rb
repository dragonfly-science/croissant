require "rails_helper"

RSpec.describe Survey, type: :model do
  subject { FactoryBot.create(:survey) }

  it { is_expected.to have_attribute :consultation_id }

  it "has the original file filename" do
    expect(subject.original_file.filename).to eq("survey_upload.csv")
  end

  it "is invalid without a consultation" do
    subject.consultation = nil
    expect(subject).not_to be_valid
  end

  context "with submissions" do
    it "has a submission" do
      FactoryBot.create(:submission, :ready_to_tag, survey_id: subject.id)
      expect(subject.submissions).not_to be_blank
    end
  end
end
