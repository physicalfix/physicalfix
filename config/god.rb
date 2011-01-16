RAILS_ROOT = "/data/physicalfix/current"
#vid2s3 sinatra
God.watch do |w|
  w.name = "vid2s3"
  w.interval = 30.seconds
  w.start = "sudo thin -C #{RAILS_ROOT}/lib/vid2s3/config.yml -R #{RAILS_ROOT}/lib/vid2s3/config.ru start"
  
  w.pid_file = "#{RAILS_ROOT}/lib/vid2s3/thin.pid"
  
  w.behavior(:clean_pid_file)
  
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end
end

#rtmplite
God.watch do |w|
  w.name = 'rtmplite'
  w.interval = 30.seconds
  
  w.start = "python #{RAILS_ROOT}/vendor/rtmplite/rtmp.py -r /mnt/videos"
  
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end
end 
