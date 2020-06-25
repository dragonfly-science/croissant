class RemoveSubmissionReferenceFromSubmissionTags < ActiveRecord::Migration[6.0]
  def change
    remove_reference(:submission_tags, :submission, index: true)
  end
end
