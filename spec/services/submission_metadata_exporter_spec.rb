require "rails_helper"

RSpec.describe SubmissionMetadataExporter do
  let(:consultation) { FactoryBot.create(:consultation, name: "With a Space") }
  let!(:survey) { FactoryBot.create(:survey, consultation: consultation) }
  let!(:submission1) { FactoryBot.create(:submission, :ready_to_tag, consultation: consultation, survey: survey) }
  let!(:submission2) { FactoryBot.create(:submission, :ready_to_tag, consultation: consultation) }

  # to test for false positive inclusions
  let!(:other_consult) { FactoryBot.create(:consultation) }
  let!(:other_submission) { FactoryBot.create(:submission, :ready_to_tag, consultation: other_consult) }

  subject { SubmissionMetadataExporter.new(consultation) }

  it "creates a CSV with columns of information about the submission" do
    metadata_column_names = Submission::METADATA_FIELDS.join(",")
    csv = subject.export
    expect(csv).to start_with("submission_id,filename,part_number,survey_id,text,"\
                              "state,loaded_by,#{metadata_column_names}\n")
  end

  it "includes SubmissionParts for all submissions for the consultation" do
    submissions = [
      SubmissionPart.new(submission1, 1, submission1.text),
      SubmissionPart.new(submission2, 1, submission2.text)
    ]
    expect(subject.export.lines.count).to eq(submissions.count + 1)
    expect(subject.items.to_a).to match_array(submissions)
  end

  it "includes the full number, name and ID for each tag" do
    csv = subject.export
    expect(csv).to include("#{submission1.id},00988_Anonymous.pdf,1,#{survey.id},"\
                           "#{submission1.text},#{submission1.state},\"\",")
    expect(csv).to include("#{submission2.id},00988_Anonymous.pdf,1,\"\","\
                           "#{submission2.text},#{submission2.state},\"\",")
  end

  it "includes the date and consultation name in the filename" do
    expect(subject.filename).to eq("#{Time.zone.today.iso8601}-with-a-space-submissions.csv")
  end

  context "for submissions with macrons" do
    let!(:submission1) do
      FactoryBot.create(:submission, :ready_to_tag, text: "Kia ora whānau", consultation: consultation)
    end
    it "can deal with them" do
      csv = subject.export
      expect(csv).to include("#{submission1.id},00988_Anonymous.pdf,1,\"\","\
                             "#{submission1.text},#{submission1.state},\"\",")
    end
  end

  context "for long text" do
    let!(:submission1) do
      FactoryBot.create(:submission, :ready_to_tag, consultation: consultation,
                                                    text: Faker::Lorem.characters(number: 401))
    end
    let!(:submission2) do
      FactoryBot.create(:submission, :ready_to_tag, consultation: consultation,
                                                    text: Faker::Lorem.characters(number: 199))
    end
    subject { SubmissionMetadataExporter.new(consultation, character_limit: 200) }

    it "splits up submissions into separate lines" do
      csv = subject.export
      expect(csv.lines.count).to eq(5)
      expect(csv).to include("#{submission1.id},00988_Anonymous.pdf,1,\"\",#{submission1.text[0..199]}")
      expect(csv).to include("#{submission1.id},00988_Anonymous.pdf,2,\"\",#{submission1.text[200..399]}")
      expect(csv).to include("#{submission1.id},00988_Anonymous.pdf,3,\"\",#{submission1.text[400..401]}")
      expect(csv).to include("#{submission2.id},00988_Anonymous.pdf,1,\"\",#{submission2.text}")
    end
  end
end
