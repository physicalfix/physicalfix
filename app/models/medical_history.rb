class MedicalHistory < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :p_name, :p_number, :health, :fitness, :contact_p, :illness, :problems, :bone, :pain, :medication, :routine, :p_visit, :p_visit_text, :exercise
  validates_length_of :p_number, :within => 5..16
  validates_format_of :p_number, :with => /^[+\/\- () 0-9]+$/
  
  validates_presence_of :exercise_text, :if => Proc.new {|medical_history| medical_history.exercise == 'yes'}
  validates_presence_of :illness_text,  :if => Proc.new {|medical_history| medical_history.illness  == 'yes'}
  validates_presence_of :problems_text, :if => Proc.new {|medical_history| medical_history.problems  == 'yes'}
  validates_presence_of :bone_text, :if => Proc.new {|medical_history| medical_history.bone  == 'yes'}
  validates_presence_of :pain_text, :if => Proc.new {|medical_history| medical_history.pain  == 'yes'}
  validates_presence_of :medication_text, :if => Proc.new {|medical_history| medical_history.medication  == 'yes'}
  validates_presence_of :routine_text, :if => Proc.new {|medical_history| medical_history.routine  == 'yes'}
    
  HUMANIZED_ATTRIBUTES = {
    :p_name => "Question 1",
    :p_number => "Question 2",
    :p_visit => "Question 3",
    :p_visit_text => "Question 4",
    :exercise => "Question 5",
    :exercise_text => "Question 5a",
    :contact_p => "Question 6",
    :experience => "Question 7",
    :diagnose => "Question 8",
    :illness => "Question 9",
    :illness_text => "Question 9a",
    :problems => "Question 10",
    :problems_text => "Question 10a",
    :bone => "Question 11",
    :bone_text => "Question 11a",
    :pain => "Question 12",
    :pain_text => "Question 12a",
    :medication => "Question 13",
    :medication_text => "Question 13a",
    :health => "Question 14",
    :fitness => "Question 15",
    :routine => "Question 16",
    :routine_text => "Question 16a"
  }
  
  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  #alias_attribute :name_of_physician, :p_name 
end
