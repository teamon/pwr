# coding: utf-8
require "rubygems"
require 'nokogiri'
require "pdfkit"
require 'icalendar'
require 'vpim'
require "haml"

Dir[File.dirname(__FILE__) + "/lib/**/*.rb"].each {|f| require f }
Dir[File.dirname(__FILE__) + "/semesters/*.rb"].each {|f| require f }

case ARGV[0]
when "pdf"
  days = EclParser::Plan.parse!(File.read(ARGV[1]))
  pdf = PlanGenerator::PDF.generate!(days)
  File.open("test.pdf", "wb") {|f| f.write pdf }
  system("open test.pdf")
when "pdfkit"
  days = EclParser::Plan.parse!(File.read(ARGV[1]))
  pdf = PlanGenerator::PDFKit.generate!(days)
  File.open("test.pdf", "wb") {|f| f.write pdf }
  system("open test.pdf")
when "ical"
  days = EclParser::Plan.parse!(File.read(ARGV[1]))
  ical = PlanGenerator::ICal.generate!(days)
  File.open("test.ics", "wb") {|f| f.write ical }
  system("open test.ics")
when "vcs"
  days = EclParser::Plan.parse!(File.read(ARGV[1]))
  cal = PlanGenerator::VCS.generate!(days)
  File.open("test.vcs", "wb") {|f| f.write cal }
  system("mate test.vcs")
when "avg"
  avr = EclParser::Avg.parse!(File.read(ARGV[1]))
when "pdf-all"
  Dir.chdir("tests") do
    Dir["*.html"].each do |file|
      puts file
      days = EclParser::Plan.parse!(File.read(file))
      pdf = PlanGenerator::PDF.generate!(days)
      File.open("#{file}.pdf", "wb") {|f| f.write pdf }
      system("open #{file}.pdf")
    end
  end
end