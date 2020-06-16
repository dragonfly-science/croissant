class Survey < ApplicationRecord
  has_paper_trail

  belongs_to :consultation
  has_one_attached :original_file
  has_many :survey_questions, dependent: :destroy
  has_many :submissions, dependent: :destroy

  SURVEY_FILE_TYPES = %w[text/csv
                         application/vnd.openxmlformats-officedocument.spreadsheetml.sheet].freeze

  validates :original_file, blob: {
    content_type: SURVEY_FILE_TYPES
  }

  def filename
    return original_file.filename if original_file&.attached?

    nil
  end
end
