# coding: utf-8

Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

require 'sinatra'
require "haml"
require 'nokogiri'
require "pdfkit"
require 'icalendar'
require 'vpim'
require "prawn"
require "prawn/layout"

Dir[File.dirname(__FILE__) + "/lib/**/*.rb"].each {|f| require f }
Dir[File.dirname(__FILE__) + "/semesters/*.rb"].each {|f| require f }
# 
# PDFKit.configure do |config|
#   config.wkhtmltopdf = File.join(File.dirname(__FILE__), 'bin')
# end

get "/" do
  haml :index
end

get "/error" do
  haml :error
end

get "/plan" do
  haml :plan
end

post "/plan" do
  begin
    if params[:data]
      schedule = EclParser::Plan.parse!(params[:data])
      
      case params[:type]
      when "pdf"
        content_type "application/pdf"
        attachment "plan-pwr.pdf"
        PlanGenerator::PDF.generate!(schedule)
      when "pdfkit"
        content_type "application/pdf"
        attachment "plan-pwr.pdf"
        PlanGenerator::PDFKit.generate!(schedule)
      when "html"
        content_type "text/html"
        attachment "plan-pwr.html"
        PlanGenerator::HTML.generate!(schedule)
      when "ical"
        content_type 'text/plain'
        attachment "plan-pwr.ics"
        PlanGenerator::ICal.generate!(schedule)
      when "vcs"
        content_type 'text/X-vCalendar'
        attachment "plan-pwr.vcs"
        PlanGenerator::VCS.generate!(schedule)
      else
        raise ArgumentError
      end
    else
      redirect "/error"
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace
    redirect "/error"
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
    puts e.message
    puts e.backtrace
    redirect "/error"
  end
    
  haml :srednia
end