class SubmissionTag < ApplicationRecord
  belongs_to :submission
  belongs_to :tag

  delegate :name, :colour_number, :full_number, to: :tag
  delegate :filename, to: :submission
  delegate :id, to: :submission, prefix: true
  delegate :id, to: :tag, prefix: true

  before_validation do
    remove_forced_carriage_returns_from_text
    update_position if start_or_end_char_absent_or_negative?
  end

  before_create { submission.tag }

  validates_numericality_of :start_char, less_than: ->(st) { st.end_char }
  validates_numericality_of :start_char, greater_than_or_equal_to: 0
  validates_numericality_of :end_char, less_than: ->(st) { st.submission.text.length }

  def calculated_text
    submission.text[(start_char)..(end_char)]
  end

  def calculated_position
    return nil unless text_in_submission?

    start_position = submission.text.index(text)
    end_position = start_position + text.length - 1
    [start_position, end_position]
  end

  def text_in_submission?
    submission.text.include?(text)
  end

  def dissonant?
    text != calculated_text
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
