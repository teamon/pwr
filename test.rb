require "rubygems"
require "lib/data"
require "lib/parser"
require "lib/ical"
require "lib/pdf"

days = EclParser.parse!(File.read(ARGV[1]))

case ARGV[0]
when "pdf"
  pdf = PdfGenerator.generate!(days)

  File.open("test.pdf", "wb") {|f| f.write pdf }
  system("open test.pdf")
  
when "ical"
  ical = ICalGenerator.generate!(days)

  File.open("test.ics", "wb") {|f| f.write ical }
  system("open test.ics")
end