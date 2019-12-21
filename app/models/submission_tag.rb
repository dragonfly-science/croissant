class SubmissionTag < ApplicationRecord
  belongs_to :submission
  belongs_to :tag
  delegate :name, to: :tag

  validates_numericality_of :start_char, less_than: ->(st) { st.end_char }

  def calculated_text
    submission.text[(start_char)..(end_char)]
  end
end
