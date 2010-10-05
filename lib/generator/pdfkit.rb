# encoding: utf-8

module PlanGenerator
  class PDFKit 
    OPTIONS = {
      :orientation => "Landscape", 
      :margin_top => '5mm',
      :margin_bottom => '5mm',
      :margin_left => '5mm',
      :margin_right => '5mm'
    }
    
    def self.generate!(schedule)
      ::PDFKit.new(PlanGenerator::HTML.generate!(schedule), OPTIONS).to_pdf
    end
  end
  
  class MiniPDFKit < PDFKit
    def self.generate!(schedule)
      ::PDFKit.new(PlanGenerator::MiniHTML.generate!(schedule), OPTIONS).to_pdf
    end
  end
end