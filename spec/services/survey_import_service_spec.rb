require "rails_helper"

RSpec.describe SurveyImportService do
  let!(:survey_import_1) { FactoryBot.create(:survey_import) }

  let!(:file_csv_2) { Rack::Test::UploadedFile.new("spec/support/example_files/survey_upload_2.csv", "text/csv") }
  let!(:survey_import_2) do
    FactoryBot.create(:survey_import, consultation: survey_import_1.consultation, file: file_csv_2)
  end

  let!(:file_xlsx) do
    Rack::Test::UploadedFile.new("spec/support/example_files/ex_xlxs.xlsx",
                                 "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  end

  let!(:survey_import_3) do
    FactoryBot.create(:survey_import, consultation: survey_import_1.consultation, file: file_xlsx)
  end

  let!(:survey_monkey_file_xlsx) do
    Rack::Test::UploadedFile.new("spec/support/example_files/survey_monkey_example.xlsx",
                                 "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  end

  let!(:survey_import_4) do
    FactoryBot.create(:survey_import, consultation: survey_import_1.consultation, file: survey_monkey_file_xlsx)
  end

  context "when the file is of type csv" do
    subject { SurveyImportService.new(survey_import_1.file, survey_import_1.consultation) }
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
      expect(survey_import_1.consultation.submissions.count).to eq(4)
    end

    it "creates survey answers" do
      expect { subject.import! }.to change { SurveyAnswer.count }.by(12)
    end

    it "creates submissions with a concatenated question and answer as text" do
      subject.import!
      expect(survey_import_1.consultation.submissions.last.text).to include(
        "****SQ_#{Survey.last.id}_#{SurveyQuestion.first.id}****Nope\n")
    end

    context "when multiple surveys are uploaded" do
      context "when questions have the same text" do
        it "creates survey answers only for questions related to the survey" do
          subject.import!
          expect(Survey.count).to eq(1)
          expect(SurveyAnswer.count).to eq(12)
          expect(Survey.last.survey_questions.first.question).to eq("question_1")
          SurveyImportService.new(survey_import_2.file, survey_import_2.consultation).import!
          expect(Survey.count).to eq(2)
          expect(SurveyAnswer.count).to eq(13)
          expect(Survey.last.survey_questions.first.question).to eq("question_1")
        end
      end
    end
  end

  context "when the file is of type xlsx" do
    subject { SurveyImportService.new(survey_import_3.file, survey_import_3.consultation) }

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
      expect(survey_import_3.consultation.submissions.count).to eq(2)
    end

    it "creates survey answers" do
      expect { subject.import! }.to change { SurveyAnswer.count }.by(6)
    end

    it "creates submissions with a concatenated question and answer as text" do
      subject.import!
      expect(survey_import_3.consultation.submissions.last.text).to include(
        "****SQ_#{Survey.last.id}_#{SurveyQuestion.first.id}****No\n")
    end
  end

  context "when the upload file is from survey monkey" do
    subject { SurveyImportService.new(survey_import_4.file, survey_import_4.consultation) }

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
      expect { subject.import! }.to change { SurveyQuestion.count }.by(31)
    end

    it "creates submissions within the consultation" do
      subject.import!
      expect(survey_import_3.consultation.submissions.count).to eq(51)
    end

    it "creates survey answers" do
      expect { subject.import! }.to change { SurveyAnswer.count }.by(1073)
    end

    it "creates submissions with a concatenated question and answer as text" do
      subject.import!
      expect(survey_import_3.consultation.submissions.last.text).to include(
        "****SQ_#{Survey.last.id}_#{Survey.last.survey_questions.first.id}****3190524450\n")
    end
  end
end
