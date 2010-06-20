# encoding: utf-8

require "rubygems"
require "sinatra"
require "lib/data"
require "lib/parser"
require "lib/pdf"
require "lib/pdfkit"
require "lib/ical"
require "lib/vcs"
require "lib/srednia"

get "/" do
  erb :index
end

get "/plan" do
  erb :plan
end

post "/plan" do
  begin
    if params[:data]
      schedule = EclParser.parse!(params[:data])
      
      case params[:type]
      when "pdf"
        content_type "application/pdf"
        attachment "plan-pwr.pdf"
        PdfGenerator.generate!(schedule)
      when "pdfkit"
        content_type "application/pdf"
        attachment "plan-pwr-pdfkit.pdf"
        PdfKitGenerator.generate!(schedule)
      when "ical"
        content_type 'text/calendar'
        attachment "plan-pwr.ics"
        ICalGenerator.generate!(schedule)
      when "vcs"
        content_type 'text/X-vCalendar'
        attachment "plan-pwr.vcs"
        VCSGenerator.generate!(schedule)
      else
        raise ArgumentError
      end
    else
      "Error!"
    end
  rescue Exception => e
    p e
    "Error!. Skontaktuj sie z administratorem ;]"
  end
end

get "/srednia" do
  erb :srednia
end

post "/srednia" do
  begin
    if params[:data]
      @avg = EclParserS.parse!(params[:data])
    else
      "Error!"
    end
  rescue Exception => e
    p e
    "Error!. Skontaktuj sie z administratorem ;]"
  end
  
  erb :srednia
end