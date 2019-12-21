class Submission < ApplicationRecord
  METADATA_FIELDS = %i[description submitted_at channel source name submitter_type
                       email_address address phone_number query_type anonymise
                       exemplar maori_perspective pacific_perspective high_impact_stakeholder
                       high_relevance_stakeholder age_bracket ethnicity gender].freeze

  SUBMITTER_TYPES = %w[individual group].freeze

  belongs_to :consultation
  has_one_attached :file
  has_many :submission_tags, dependent: :destroy
  has_many :tags, through: :submission_tags

  validates :file, presence: true, blob: {
    content_type: ["application/pdf",
                   "application/msword",
                   "application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
  }

  validates :submitter_type, inclusion: { in: SUBMITTER_TYPES }, allow_blank: true

  state_machine :state, initial: :incoming do
    event :process do
      transition incoming: :ready, unless: :text_blank?
    end

    event :tag do
      transition ready: :started
    end

    event :complete_tagging do
      transition started: :finished
    end

    event :reject do
      transition finished: :started
    end
  end

  delegate :filename, to: :file

  def raw_text
    file.analyzed? ? file.metadata[:text] : ""
  end

  def populate_text_from_file_if_present
    self.text = raw_text if file.analyzed? && text.blank?
    save
  end

  delegate :blank?, to: :text, prefix: true
end
