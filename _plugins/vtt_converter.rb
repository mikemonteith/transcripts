require 'webvtt'

module Jekyll
  class VttConverter < Converter
    safe true
    priority :low

    def matches(ext)
      print "Checking extension: #{ext}\n"
    end

    def output_ext(ext)
      '.html'
    end

    def convert(content)
      vtt = WebVTT.parse(content)
      subtitles = vtt.cues.map do |cue|
        {
          start: cue.start,
          end: cue.end,
          text: cue.text
        }
      end
      render_subtitles(subtitles)
    end

    def render_subtitles(subtitles)
      html = <<~HTML
        <div class="subtitles">
          #{subtitles.map { |sub| subtitle_html(sub) }.join}
        </div>
      HTML

      html
    end

    def subtitle_html(subtitle)
      escaped_text = subtitle[:text].gsub('<', '&lt;').gsub('>', '&gt;')
      <<~HTML
        <div class="subtitle" data-start="#{subtitle[:start]}" data-end="#{subtitle[:end]}">
          <span class="time">#{subtitle[:start]} → #{subtitle[:end]}</span>
          <p class="text">#{escaped_text}</p>
        </div>
      HTML
    end
  end
end
