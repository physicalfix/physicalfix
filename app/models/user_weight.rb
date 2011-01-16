class UserWeight < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :weight
  validates_numericality_of :weight

  has_attached_file :weight_image,
                    :storage => :s3,
                    :styles => {
                      :screen => "500x500>",
                      :thumb => "100x100>"
                    },
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :bucket => "myfitstream",
                    :path => ":class/:id/:style.:extension"
  
  protected
   def validate
     u = User.find(user_id)
     return unless u.user_weights.size > 0
     errors.add_to_base("Only one weight can be added each day") if u.user_weights.find(:all, :order => 'user_weights.created_at DESC', :limit => 1)[0].created_at.strftime("%F") == Time.zone.now.to_date.to_s
   end
  
end
