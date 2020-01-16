class Tag < ApplicationRecord
  belongs_to :taxonomy

  belongs_to :parent, class_name: "Tag", optional: true
  has_many :children, class_name: "Tag", foreign_key: "parent_id",
                      inverse_of: :parent, dependent: :destroy
  has_many :submission_tags, dependent: :destroy
  has_many :submissions, through: :submission_tags

  before_create :create_number
  before_destroy :check_deletability, prepend: true

  validates :name, presence: true, uniqueness: { scope: %i[taxonomy parent_id] }

  scope :top_level, -> { where(parent_id: nil) }

  def deletable?
    submissions.none?
  end

  def full_number
    @full_number ||= calculate_full_number
  end

  def full_name
    @full_name ||= calculate_full_name
  end

  def colour_number
    full_number[0]
  end

  def numbering_context
    parent.present? ? parent.children : taxonomy.tags.top_level
  end

  private

  def calculate_full_number
    parent.present? ? "#{parent.full_number}.#{number}" : number
  end

  def calculate_full_name
    parent.present? ? "#{parent.full_name} > #{name}" : name
  end

  def in_same_taxonomy?(other)
    other.taxonomy == taxonomy
  end

  def create_number
    self.number ||= TagNumberer.new_number_for(numbering_context)
  end

  def check_deletability
    return true if deletable?

    errors.add(:base, "Cannot delete tag that has been used")
    throw :abort
  end
end
