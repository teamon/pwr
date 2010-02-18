require "rubygems"
require "parser"

File.open("test.pdf", "wb") {|f| f.write EclParser.generate!(File.read(ARGV.first)) }
system("open test.pdf")