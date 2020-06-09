SubmissionPart = Struct.new(:submission, :part_number, :text) do
  delegate :id, :filename, :state, :survey_id, *Submission::METADATA_FIELDS, to: :submission
end
