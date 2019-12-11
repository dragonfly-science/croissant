class Tag < ApplicationRecord
  belongs_to :taxonomy

  belongs_to :parent, class_name: "Tag", optional: true
  has_many :children, class_name: "Tag", foreign_key: "parent_id",
                      inverse_of: :parent, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :taxonomy }

  private

  def in_same_taxonomy?(other)
    other.taxonomy == taxonomy
  end
end