require "rails_helper"
RSpec.describe SubmissionFilter do
  let!(:single_page_submission) do
    file = Rack::Test::UploadedFile.new("spec/support/example_files/single-page.pdf",
                                        "application/pdf")
    FactoryBot.create(:submission, file: file)
  end
  let!(:started_submission) { FactoryBot.create(:submission, :ready_to_tag, state: "started") }
  let!(:finished_submission) { FactoryBot.create(:submission, :finished) }
  let!(:archived_submission) { FactoryBot.create(:submission, state: "archived") }
  let(:submissions) { Submission.all }
  let(:params) { {} }
  subject { SubmissionFilter.new(submissions, params) }

  it "excludes archived submissions by default" do
    expect(subject.filter.to_a).not_to include(archived_submission)
  end
  it "does not consider that an active filter" do
    subject.filter
    expect(subject.active_filters).to eq({})
  end
  context "including archived submissions" do
    let(:params) { { include_archived: true } }
    it "allows including archived submissions" do
      expect(subject.filter.to_a).to include(archived_submission)
    end
  end

  context "filtering submissions by filename" do
    let(:params) { { filename: "single-page" } }
    it "finds submissions with matching filenames only" do
      expect(subject.filter.to_a).to eq([single_page_submission])
    end
    it "includes filename as an active filter" do
      subject.filter
      expect(subject.active_filters.keys).to eq([:filename])
    end
  end
  context "filtering submissions by one state" do
    let(:params) { { state: "started" } }
    it "finds submissions with matching state only" do
      expect(subject.filter.to_a).to eq([started_submission])
    end
    it "includes state as an active filter" do
      subject.filter
      expect(subject.active_filters.keys).to eq([:state])
    end
  end
  context "filtering submissions by multiple states" do
    let(:params) { { state: %w[started finished] } }
    it "finds submissions with matching state only" do
      expect(subject.filter.to_a).to contain_exactly(started_submission, finished_submission)
    end
  end
  context "multiple filters" do
    let!(:single_page_started_submission) do
      file = Rack::Test::UploadedFile.new("spec/support/example_files/single-page.pdf",
                                          "application/pdf")
      FactoryBot.create(:submission, file: file, state: "started")
    end
    let(:params) { { state: "started", filename: "single-page" } }

    it "finds submissions that match all filters" do
      expect(subject.filter.to_a).to eq([single_page_started_submission])
    end
    it "includes the active filters" do
      subject.filter
      expect(subject.active_filters.keys).to eq(%i[state filename])
    end
  end
end
