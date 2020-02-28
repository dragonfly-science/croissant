class Submission < ApplicationRecord
  has_paper_trail
  METADATA_FIELDS = %i[description submitted_at channel source name submitter_type
                       email_address address phone_number query_type anonymise
                       exemplar maori_perspective pacific_perspective high_impact_stakeholder
                       high_relevance_stakeholder age_bracket ethnicity gender].freeze

  SUBMITTER_TYPES = %w[individual group].freeze
  SUBMISSION_FILE_TYPES = %w[application/pdf application/msword
                             application/vnd.openxmlformats-officedocument.wordprocessingml.document].freeze

  belongs_to :consultation
  has_one_attached :file
  has_many :submission_tags, dependent: :destroy
  has_many :tags, through: :submission_tags

  validates :file, presence: true, blob: {
    content_type: SUBMISSION_FILE_TYPES
  }

  validates :submitter_type, inclusion: { in: SUBMITTER_TYPES }, allow_blank: true

  before_update :remove_forced_carriage_returns_from_text

  delegate :filename, to: :file
  delegate :blank?, to: :text, prefix: true

  scope :active, -> { where.not(state: "archived") }

  state_machine :state, initial: :incoming do
    event :process do
      transition incoming: :ready, unless: :text_blank?
    end

    event :tag do
      transition ready: :started
      transition started: :started # so can_tag?
    end

    event :complete_tagging do
      transition started: :finished
    end

    event :archive do
      transition %i[ready started] => :archived
    end

    event :reject do
      transition finished: :started
    end

    event :restore do
      transition archived: :started
    end
  end

  def can_delete?
    incoming?
  end

  def can_edit?
    incoming? && file.analyzed?
  end

  def raw_text
    file.analyzed? ? file.metadata[:text] : ""
  end

  def populate_text_from_file_if_present
    self.text = raw_text if file.analyzed? && text.blank?
    save
  end

  def add_tag(params)
    return false unless can_tag?

    tag
    submission_tags.create(params)
  end

  private

  def remove_forced_carriage_returns_from_text
    text&.gsub!(/\r\n/, "\n")
  end
end
