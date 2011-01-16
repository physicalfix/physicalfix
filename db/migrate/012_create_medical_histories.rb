class CreateMedicalHistories < ActiveRecord::Migration
  def self.up
    create_table :medical_histories do |t|
      t.integer :user_id
      t.string :p_name, :p_number, :health, :fitness, :exercise, :contact_p, :illness, :problems, :bone, :pain, :medication, :routine
      t.date  :p_visit
      t.text :p_visit_text, :exercise_text, :illness_text, :problems_text, :bone_text, :pain_text, :medication_text, :routine_text, :experience, :diagnose
      t.timestamps
    end
  end

  def self.down
    drop_table :medical_histories
  end
end
