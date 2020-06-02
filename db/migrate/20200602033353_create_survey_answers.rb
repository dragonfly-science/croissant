class CreateSurveyAnswers < ActiveRecord::Migration[6.0]
  def change
    create_table :survey_answers do |t|
      t.references :survey_question, null: false, foreign_key: true
      t.references :submission, null: false, foreign_key: true
      t.text :answer, null: false

      t.timestamps
    end
  end
end
