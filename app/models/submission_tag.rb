class SubmissionTag < ApplicationRecord
  belongs_to :submission
  belongs_to :tag

  delegate :name, :colour_number, :full_number, to: :tag
  delegate :filename, to: :submission

  validates_numericality_of :start_char, less_than: ->(st) { st.end_char }

  def calculated_text
    submission.text[(start_char)..(end_char)]
  end

  delegate :id, to: :submission, prefix: true

  delegate :id, to: :tag, prefix: true
end
