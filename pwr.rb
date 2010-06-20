# coding: utf-8

require 'sinatra'
require "haml"
require 'nokogiri'
require "pdfkit"
require 'icalendar'
require 'vpim'

Dir[File.dirname(__FILE__) + "/lib/**/*.rb"].each {|f| require f }
Dir[File.dirname(__FILE__) + "/semesters/*.rb"].each {|f| require f }

get "/" do
  haml :index
end

get "/plan" do
  haml :plan
end

post "/plan" do
  p params
  begin
    if params[:data]
      schedule = EclParser::Plan.parse!(params[:data])
      
      case params[:type]
      when "pdf"
        content_type "application/pdf"
        attachment "plan-pwr.pdf"
        PlanGenerator::PDF.generate!(schedule)
      when "ical"
        content_type 'text/plain'
        # attachment "plan-pwr.ics"
        PlanGenerator::ICal.generate!(schedule)
      when "vcs"
        content_type 'text/X-vCalendar'
        attachment "plan-pwr.vcs"
        PlanGenerator::VCS.generate!(schedule)
      else
        raise ArgumentError
      end
    else
      "Error!"
    end
  rescue Exception => e
    content_type 'text/plain'
    puts e.message
    puts e.backtrace
    "Error!. Skontaktuj sie z administratorem ;]"
  end
end

get "/srednia" do
  haml :srednia
end

post "/srednia" do
  begin
    if params[:data]
      @avg = EclParser::Avg.parse!(params[:data])
    else
      redirect "/srednia"
    end
  rescue Exception => e
    p e
    "Error!. Skontaktuj sie z administratorem ;]"
  end
  
  puts "".encoding
  
  content_type :html, :charset => 'utf-8'
  haml :srednia
end