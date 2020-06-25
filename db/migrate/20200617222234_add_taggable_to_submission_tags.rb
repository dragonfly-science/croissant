class AddTaggableToSubmissionTags < ActiveRecord::Migration[6.0]
  def change
    change_table :submission_tags, bulk: true do |t|
      t.references :taggable, polymorphic: true
    end
  end
end
