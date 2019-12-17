class Tag < ApplicationRecord
  belongs_to :taxonomy

  belongs_to :parent, class_name: "Tag", optional: true
  has_many :children, class_name: "Tag", foreign_key: "parent_id",
                      inverse_of: :parent, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: %i[taxonomy parent_id] }

  scope :top_level, -> { where(parent_id: nil) }

  private

  def in_same_taxonomy?(other)
    other.taxonomy == taxonomy
  end
end
