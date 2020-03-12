# frozen_string_literal: true

class TxtAnalyzer < ActiveStorage::Analyzer
  require "charlock_holmes"
  def self.accept?(blob)
    blob.content_type == "text/plain"
  end

  def metadata
    {
      text: read_txt
    }
  end

  private

  def read_txt
    output_text = ""
    download_blob_to_tempfile do |file|
      file.each_line do |line|
        output_text += line
      end
    end
    detect_encoding(output_text)
  end

  def detect_encoding(text)
    detection = CharlockHolmes::EncodingDetector.detect(text)
    if detection[:encoding] == "UTF-8"
      text.force_encoding("UTF-8")
    else
      text = CharlockHolmes::Converter.convert(text, detection[:encoding], "UTF-8")
    end
    text
  end
end
