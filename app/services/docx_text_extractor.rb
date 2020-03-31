class DocxTextExtractor
  def self.call(file)
    paragraphs = []
    document = Docx::Document.open(file)
    document.paragraphs.each do |paragraph|
      paragraphs << paragraph
    end
    paragraphs.join("\n")
  end
end
