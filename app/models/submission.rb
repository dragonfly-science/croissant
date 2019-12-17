class Submission < ApplicationRecord
  belongs_to :consultation
  has_one_attached :file

  validates :file, presence: true, blob: {
    content_type: ["application/pdf",
                   "application/msword",
                   "application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
  }

  def name
    file.filename
  end
end
