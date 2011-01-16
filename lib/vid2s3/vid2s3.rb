require 'rubygems'
require 'sinatra'
require 'aws/s3'

AWS::S3::Base.establish_connection!(
  :access_key_id     => 'AKIAJQURUF2GSNV4C5YQ',
  :secret_access_key => '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'
)

PATH = '/mnt/videos'
get '/crossdomain.xml' do
  '<cross-domain-policy><allow-access-from domain="*"/><site-control permitted-cross-domain-policies="master-only"/></cross-domain-policy>'
end

get '/process' do
  video_id = params[:id]
  
  video_path = "#{PATH}#{video_id}.flv"
  thumb_path = "#{PATH}#{video_id}.jpg" 
  
  #create thumbnail
  output = `ffmpeg -itsoffset 1 -i "#{video_path}" -y -vcodec mjpeg -vframes 1 -an -f rawvideo "#{thumb_path}"`
  
  begin
    #upload video & thumbnail to S3
    AWS::S3::S3Object.store(
      "webcam/#{video_id}.flv",
      File.open(video_path),
      'myfitstream',
      :access => :public_read
    )
  
    AWS::S3::S3Object.store(
      "webcam/#{video_id}.jpg",
      File.open(thumb_path),
      'myfitstream',
      :access => :public_read
    )
  
    File.delete(video_path)
    File.delete(thumb_path)
  rescue
    return 'failed'
  end
  'ok'
end
