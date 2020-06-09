require "rails_helper"

RSpec.describe SurveyImportService do
  let!(:consultation) { FactoryBot.create(:consultation) }
  let!(:file_csv) { Rack::Test::UploadedFile.new("spec/support/example_files/survey_upload.csv", "text/csv") }
  let!(:file_csv_2) { Rack::Test::UploadedFile.new("spec/support/example_files/survey_upload_2.csv", "text/csv") }
  let!(:file_xlsx) do
    Rack::Test::UploadedFile.new("spec/support/example_files/ex_xlxs.xlsx",
                                 "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  end

  context "when the file is of type csv" do
    subject { SurveyImportService.new(file_csv, consultation) }
    it "is valid" do
      expect(subject.valid?).to eq(true)
    end

    it "returns an empty list of validity errors" do
      expect(subject.validity_errors).to eq([])
    end

    it "creates a survey" do
      expect { subject.import! }.to change { Survey.count }.by(1)
    end

    it "creates survey questions" do
      expect { subject.import! }.to change { SurveyQuestion.count }.by(3)
    end

    it "creates submissions within the consultation" do
      subject.import!
      expect(consultation.submissions.count).to eq(4)
    end

    it "creates survey answers" do
      expect { subject.import! }.to change { SurveyAnswer.count }.by(12)
    end

    it "creates submissions with a concatenated question and answer as text" do
      subject.import!
      expect(consultation.submissions.last.text).to include(
        "****SQ_#{Survey.last.id}_#{SurveyQuestion.first.id}****Nope\n")
    end

    context "when multiple surveys are uploaded" do
      context "when questions have the same text" do
        it "creates survey answers only for questions related to the survey" do
          subject.import!
          expect(Survey.count).to eq(1)
          expect(SurveyAnswer.count).to eq(12)
          expect(Survey.last.survey_questions.first.question).to eq("question_1")
          SurveyImportService.new(file_csv_2, consultation).import!
          expect(Survey.count).to eq(2)
          expect(SurveyAnswer.count).to eq(13)
          expect(Survey.last.survey_questions.first.question).to eq("question_1")
        end
      end
    end
  end

  context "when the file is of type xlsx" do
    subject { SurveyImportService.new(file_xlsx, consultation) }

    it "is valid" do
      expect(subject.valid?).to eq(true)
    end

    it "returns an empty list of validity errors" do
      expect(subject.validity_errors).to eq([])
    end

    it "creates a survey" do
      expect { subject.import! }.to change { Survey.count }.by(1)
    end

    it "creates survey questions" do
      expect { subject.import! }.to change { SurveyQuestion.count }.by(3)
    end

    it "creates submissions within the consultation" do
      subject.import!
      expect(consultation.submissions.count).to eq(2)
    end

    it "creates survey answers" do
      expect { subject.import! }.to change { SurveyAnswer.count }.by(6)
    end

    it "creates submissions with a concatenated question and answer as text" do
      subject.import!
      expect(consultation.submissions.last.text).to include(
        "****SQ_#{Survey.last.id}_#{SurveyQuestion.first.id}****No\n")
    end
  end
end
