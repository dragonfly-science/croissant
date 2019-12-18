class Submission < ApplicationRecord
  belongs_to :consultation
  has_one_attached :file

  validates :file, presence: true, blob: {
    content_type: ["application/pdf",
                   "application/msword",
                   "application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
  }

  state_machine :state, initial: :incoming do
    event :analyze do
      transition incoming: :analyzed
    end

    event :process do
      transition %i[incoming analyzed] => :ready
    end

    event :tag do
      transition ready: :started
    end

    event :complete_tagging do
      transition started: :finished
    end

    event :qa_reject do
      transition finished: :started
    end
  end

  def name
    file.filename
  end

  def raw_text
    file.analyzed? ? file.metadata[:text] : ""
  end

  def populate_text_from_file_if_present
    self.text = raw_text if file.analyzed? && text.blank?
    save
  end
end
