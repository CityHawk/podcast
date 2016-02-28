require 'streamio-ffmpeg'
module Jekyll
  class RawContent < Generator
    def string_of_duration(duration)
      seconds = duration.to_i
      minutes = seconds / 60
      hours   = minutes / 60

      "#{"%02d" % hours}:#{"%02d" % (minutes % 60)}:#{"%02d" % (seconds % 60)}"
    end

    def generate(site)
      site.posts.docs.each do |post|
        post.data['raw_content'] = post.content
        filename = "episodes/#{post['audio']}"
        post.data['media_length'] = File.size(filename)
        media = FFMPEG::Movie.new(filename)
        post.data['media_duration'] = string_of_duration(media.duration)

      end
    end
  end
end
