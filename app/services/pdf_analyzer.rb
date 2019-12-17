# frozen_string_literal: true

class PdfAnalyzer < ActiveStorage::Analyzer
  def self.accept?(blob)
    blob.content_type == "application/pdf"
  end

  def metadata
    {
      text: read_pdf
    }
  end

  private

  def read_pdf
    text = ""
    download_blob_to_tempfile do |file|
      text = PdfTextExtractor.call(file)
    end
    text
  end
end
