require "rubygems"
require "lib/data"
require "lib/parser"
require "lib/pdf"
require "lib/ical"
require "lib/vcs"
require "lib/srednia"



case ARGV[0]
when "pdf"
  days = EclParser.parse!(File.read(ARGV[1]))
  pdf = PdfGenerator.generate!(days)
  File.open("test.pdf", "wb") {|f| f.write pdf }
  system("open test.pdf")
when "ical"
  days = EclParser.parse!(File.read(ARGV[1]))
  ical = ICalGenerator.generate!(days)
  File.open("test.ics", "wb") {|f| f.write ical }
  system("open test.ics")
when "vcs"
  days = EclParser.parse!(File.read(ARGV[1]))
  cal = VCSGenerator.generate!(days)
  File.open("test.vcs", "wb") {|f| f.write cal }
  system("mate test.vcs")
when "avg"
  avr = EclParserS.parse!(File.read(ARGV[1]))
end