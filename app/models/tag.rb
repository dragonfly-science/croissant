class Tag < ApplicationRecord
  belongs_to :taxonomy

  belongs_to :parent, class_name: "Tag", optional: true
  has_many :children, class_name: "Tag", foreign_key: "parent_id",
                      inverse_of: :parent, dependent: :destroy
  has_many :submission_tags, dependent: :destroy
  has_many :submissions, through: :submission_tags

  before_destroy :check_deletability, prepend: true

  validates :name, presence: true, uniqueness: { scope: %i[taxonomy parent_id] }

  scope :top_level, -> { where(parent_id: nil) }

  def deletable?
    submissions.none?
  end

  private

  def in_same_taxonomy?(other)
    other.taxonomy == taxonomy
  end

  def check_deletability
    return true if deletable?

    errors.add(:base, "Cannot delete tag that has been used")
    throw :abort
  end
end
