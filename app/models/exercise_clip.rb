class ExerciseClip < ActiveRecord::Base
  has_attached_file :clip,
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :bucket => "physicalfix-test",
                    :path => ":class/:id.:extension"

    
  belongs_to :exercise
  
  before_clip_post_process :get_clip_length
  
  def get_clip_length
    ct = 0.0
    file = get_file_path
    output = `ffmpeg -i #{file} 2>&1`.match(/Duration: ([^:]*):([^:]*):([^\.]*)\.([^,]*),/)
    ct += output[1].to_i * 60 * 60
    ct += output[2].to_i * 60
    ct += output[3].to_i
    ct += "0.#{output[4]}".to_f
    self.seconds = ct
  end
  
  def get_file_path
    File.expand_path(clip.queued_for_write[:original].path)
  end
  
end
