# encoding: utf-8

require "rubygems"
require "sinatra"
require "lib/data"
require "lib/parser"
require "lib/pdf"
require "lib/ical"
require "lib/vcs"

get "/" do
  erb :index
end

post "/plan" do
  begin
    if params[:data]
      schedule = EclParser.parse!(params[:data])
      
      case params[:type]
      when "pdf"
        send_data PdfGenerator.generate!(schedule), :filename => "plan-pwr.pdf", 
          :disposition => "attachment", :type => 'application/pdf'
      when "ical"
        send_data ICalGenerator.generate!(schedule), :filename => "plan-pwr.ics", 
          :disposition => "attachment", :type => 'text/calendar'
      when "vcs"
        send_data VCSGenerator.generate!(schedule), :filename => "plan-pwr.vcs",
          :disposition => "attachement", :type => 'text/X-vCalendar'
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