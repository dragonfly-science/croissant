class SurveyQuestion < ApplicationRecord
  has_paper_trail

  after_create :populate_question_token

  belongs_to :survey
  has_many :survey_answers, dependent: :destroy

  validates :question, presence: true

  def populate_question_token
    self.token = "SQ_#{survey_id}_#{id}"
  end
end
