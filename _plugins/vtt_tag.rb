require 'webvtt'

module Jekyll
  class VttIncludeTag < Liquid::Tag
    def initialize(tag_name, file_path, tokens)
      super
      @file_path = file_path.strip
    end

    def render(context)
      rendered_file_path = Liquid::Template.parse(@file_path).render(context)
      site = context.registers[:site]
      file = File.join(site.source, '_includes', rendered_file_path)
      unless File.exist?(file)
        raise "VTT file not found: #{@file_path}"
      end

      begin
        vtt = WebVTT.read(file)
        subtitles = vtt.cues.map do |cue|
          {
            start: cue.start_in_sec,
            end: cue.end_in_sec,
            text: cue.text
          }
        end
        render_subtitles(subtitles)
      rescue => e
        raise "Error parsing VTT: #{e.message}"
      end
    end

    private
    def render_subtitles(subtitles)
      html = '<div>'
      subtitles.each do |sub|
        escaped_text = sub[:text].gsub('<', '&lt;').gsub('>', '&gt;')
        html += <<~HTML
          <div class="transcript-line">
            <a class="transcript-timestamp" href="https://www.youtube.com/watch?v=EiblHqbpXHs&t=#{sub[:start]}s" target="_blank" rel="noopener noreferrer">#{format_time(sub[:start])}</a>
            <p class="transcript-text">#{escaped_text}</p>
          </div>
        HTML
      end
      html += '</div>'
      html
    end

    def format_time(seconds)
      hours = seconds / 3600
      minutes = (seconds % 3600) / 60
      secs = seconds % 60
      sprintf("%02d:%02d:%02d", hours, minutes, secs)
    end
  end
end

Liquid::Template.register_tag('vtt_include', Jekyll::VttIncludeTag)
