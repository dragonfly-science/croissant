class Taxonomy < ApplicationRecord
  belongs_to :consultation
  has_many :tags, dependent: :destroy
end
