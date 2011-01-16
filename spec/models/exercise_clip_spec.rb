require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExerciseClip do
  before do
    @ffmpeg_result = <<-END 
    FFmpeg version 0.5, Copyright (c) 2000-2009 Fabrice Bellard, et al.
      configuration: --prefix=/opt/local --disable-vhook --enable-gpl --enable-postproc --enable-avfilter --enable-avfilter-lavf --enable-libmp3lame --enable-libvorbis --enable-libtheora --enable-libdirac --enable-libschroedinger --enable-libfaac --enable-libfaad --enable-libxvid --enable-libx264 --mandir=/opt/local/share/man --enable-shared --enable-pthreads --cc=/usr/bin/gcc-4.2 --arch=x86_64 --disable-mmx --disable-mmx2 --disable-sse --disable-ssse3 --disable-amd3dnow --disable-amd3dnowext
      libavutil     49.15. 0 / 49.15. 0
      libavcodec    52.20. 0 / 52.20. 0
      libavformat   52.31. 0 / 52.31. 0
      libavdevice   52. 1. 0 / 52. 1. 0
      libavfilter    1. 4. 0 /  1. 4. 0
      libpostproc   51. 2. 0 / 51. 2. 0
      built on Sep  5 2009 16:32:44, gcc: 4.2.1 (Apple Inc. build 5646)

    Seems stream 0 codec frame rate differs from container frame rate: 59.94 (60000/1001) -> 29.97 (30000/1001)
    Input #0, mov,mp4,m4a,3gp,3g2,mj2, from 'asdf':
      Duration: 00:25:44.00, start: 0.000000, bitrate: 1341 kb/s
        Stream #0.0(eng): Video: h264, yuv420p, 768x432, 29.97 tbr, 29.97 tbn, 59.94 tbc
        Stream #0.1(eng): Audio: aac, 44100 Hz, stereo, s16
        Stream #0.2(eng): Data: rtp  / 0x20707472
        Stream #0.3(eng): Data: rtp  / 0x20707472
    At least one output file must be specified

END
end
  describe "get_file_path" do
    it "should get the full path" do
      ec = ExerciseClip.new
      ec.clip.stub!(:queued_for_write).and_return(mock('something', :[] => mock('else', :path=>'asdf')))
      ec.get_file_path.should == "#{RAILS_ROOT}/asdf"
    end
  end
  
  describe "get_clip_length" do
    it "should call ffmpeg" do
      ec = ExerciseClip.new
      ec.should_receive(:`).with("ffmpeg -i asdf 2>&1").and_return(@ffmpeg_result)
      ec.stub!(:get_file_path).and_return('asdf')
      ec.get_clip_length
    end
    it "should set the time" do 
      ec = ExerciseClip.new
      ec.stub!(:`).and_return(@ffmpeg_result)
      ec.stub!(:get_file_path).and_return('asdf')
      ec.get_clip_length
      ec.seconds.should == 1544
    end
  end
end
