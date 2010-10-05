# coding: utf-8

if defined?(Encoding)
  Encoding.default_internal = "utf-8"
  Encoding.default_external = "utf-8"
end

require 'sinatra'
require "haml"
require 'nokogiri'
require "pdfkit"
require 'ri_cal'
require 'vpim'
require "prawn"
require "prawn/layout"

Dir[File.dirname(__FILE__) + "/lib/**/*.rb"].each {|f| require f }
Dir[File.dirname(__FILE__) + "/semesters/*.rb"].each {|f| require f }

PDFKit.configure do |config|
  if RUBY_PLATFORM =~ /darwin/
    config.wkhtmltopdf = File.join(File.dirname(__FILE__), 'bin', 'wkhtmltopdf-0.9.9-OS-X.i368')
  else  
    config.wkhtmltopdf = File.join(File.dirname(__FILE__), 'bin', 'wkhtmltopdf-amd64')
  end
end

get "/" do
  haml :index
end

get "/error" do
  @msg = case params[:eid]
  when 1 then "Błąd"
  when 2 then "Brak źródło strony lub listy kursów"
  when 3 then "Podane źródło jest nieprawidłowe"
  end
  haml :error
end

get "/plan" do
  haml :plan
end

post "/plan" do
  if params[:data] && params[:data] != ""
    begin
      @schedule = EclParser::Plan.parse!(params[:data])
    rescue
      puts e.message
      puts e.backtrace
      redirect "/error?eid=3"
    end
  end
      
  if !params[:more].empty?
    unless @schedule
      @schedule = Schedule.new
      @schedule.year = "2010/2011"
      @schedule.semester = "Zimowy"
      @schedule.days = []
      7.times {|i| @schedule.days[i] = Day.new(i) }
    end
     
    params[:more].each_pair do |_, c|
      entry = Entry.new
      entry.group_code = c[:group]
      entry.course_code = c[:code]
      entry.course_name = c[:name]
      entry.lecturer = c[:lecturer]
      entry.type = Entry::TYPES.invert[c[:type]]
      entry.week = c[:week]
       
      s = c[:start].split(":")
      e = c[:end].split(":")
       
      entry.time = { :start => { :hour => s[0], :min => s[1] }, 
                      :end => { :hour => e[0], :min => e[1] } }
      entry.building = c[:building]
      entry.room = c[:room]
      @schedule.days[c[:day].to_i] << entry
    end
    
    @schedule.days.each {|d| d.sort! }
  end
  
  unless @schedule   
    redirect "/error?eid=2"
    return
  end
    
  begin
    case params[:type]
    # when "pdf"
    #   content_type "application/pdf"
    #   attachment "plan-pwr.pdf"
    #   PlanGenerator::PDF.generate!(@schedule)
    when "pdfkit"
      content_type "application/pdf"
      attachment "plan-pwr.pdf"
      PlanGenerator::PDFKit.generate!(@schedule)
    when "html"
      content_type "text/html"
      attachment "plan-pwr.html"
      PlanGenerator::HTML.generate!(@schedule)
    when "ical"
      content_type 'text/plain'
      attachment "plan-pwr.ics"
      PlanGenerator::ICal.generate!(@schedule)
    when "vcs"
      content_type 'text/X-vCalendar'
      attachment "plan-pwr.vcs"
      PlanGenerator::VCS.generate!(@schedule)
    else
      raise ArgumentError
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace
    redirect "/error?eid=1"
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