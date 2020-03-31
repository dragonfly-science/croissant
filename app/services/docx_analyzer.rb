# frozen_string_literal: true

class DocxAnalyzer < ActiveStorage::Analyzer
  require "docx"

  CONTENT_TYPES = ["application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                   "application/msword"].freeze

  def self.accept?(blob)
    CONTENT_TYPES.include?(blob.content_type)
  end

  def metadata
    {
      text: read_docx
    }
  end

  private

  def read_docx
    text = ""
    download_blob_to_tempfile do |file|
      text = DocxTextExtractor.call(file)
    end
    text
  end
end
