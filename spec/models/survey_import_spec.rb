require "rails_helper"

RSpec.describe SurveyImport, type: :model do
  subject { FactoryBot.create(:survey_import) }

  it { is_expected.to have_attribute :consultation_id }

  it "has the file filename" do
    expect(subject.file.filename).to eq("survey_upload.csv")
  end

  it "is invalid without a consultation" do
    subject.consultation = nil
    expect(subject).not_to be_valid
  end
end
