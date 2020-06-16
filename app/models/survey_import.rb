class SurveyImport < ApplicationRecord
  has_paper_trail

  belongs_to :consultation
  has_one_attached :file
end
