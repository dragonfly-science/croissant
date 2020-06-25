class SubmissionTag < ApplicationRecord
  has_paper_trail

  belongs_to :taggable, polymorphic: true
  belongs_to :tag
  belongs_to :tagger, class_name: "User", foreign_key: "tagger_id",
                      optional: true, inverse_of: "submission_tags"

  delegate :name, :colour_number, :full_number, to: :tag
  delegate :filename, to: :taggable
  delegate :id, to: :taggable, prefix: true
  delegate :id, to: :tag, prefix: true
  delegate :email, to: :tagger, prefix: true, allow_nil: true

  before_validation do
    remove_forced_carriage_returns_from_text
    update_position if start_or_end_char_absent_or_negative?
  end

  before_create { taggable.tag }

  validates_numericality_of :start_char, less_than: ->(st) { st.end_char }
  validates_numericality_of :start_char, greater_than_or_equal_to: 0
  validates_numericality_of :end_char, less_than: ->(st) { st.taggable.text.length }

  def calculated_text
    taggable.text[(start_char)..(end_char)]
  end

  def calculated_position
    return nil unless text_in_submission?

    start_position = taggable.text.index(text)
    end_position = start_position + text.length - 1
    [start_position, end_position]
  end

  def text_in_submission?
    taggable.text.include?(text)
  end

  def dissonant?
    text != calculated_text
  end

  def submission_id
    if taggable.class.name == "Submission"
      taggable.id
    else
      taggable.submission_id
    end
  end

  def survey_question_token
    return nil if taggable.class.name == "Submission"

    taggable.survey_question&.token
  end

  private

  def remove_forced_carriage_returns_from_text
    text&.gsub!(/\r\n/, "\n")
  end

  def update_position
    return false unless text_in_submission?

    self.start_char = calculated_position[0]
    self.end_char = calculated_position[1]
  end

  def start_or_end_char_absent_or_negative?
    return true if start_char.nil? || end_char.nil?

    return true if start_char.negative? || end_char.negative?

    false
  end
end
