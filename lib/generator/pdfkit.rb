# encoding: utf-8

module PlanGenerator
  class PDFKit 
    OPTIONS = {
      :orientation => "Landscape", 
      :margin_top => '3mm',
      :margin_bottom => '3mm',
      :margin_left => '3mm',
      :margin_right => '3mm'
    }
    
    def self.generate!(schedule, colors = nil)
      ::PDFKit.new(PlanGenerator::HTML.generate!(schedule, colors), OPTIONS).to_pdf
    end
  end
  
  class MiniPDFKit < PDFKit
    def self.generate!(schedule)
      ::PDFKit.new(PlanGenerator::MiniHTML.generate!(schedule), OPTIONS).to_pdf
    end
  end
end