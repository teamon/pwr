require "vpim"
require "lib/ecl_date"

Dir[File.dirname(__FILE__) + "/../semesters/*.rb"].each {|f| require f }

class VCSGenerator
  
  def self.generate!(schedule)
    cal = Vpim::Icalendar.create2
    
    EclDate.semesters[schedule.year][schedule.semester].dates.each do |date|
      schedule.days[date.wday-1].entries.select {|e| e.in_week?(date.cweek) }.each do |entry|
        cal.add_event do |e|
          e.dtstart DateTime.civil(date.year, date.month, date.day, entry.start_hour, entry.start_min)
          e.dtend   DateTime.civil(date.year, date.month, date.day, entry.end_hour, entry.end_min)
          e.summary entry.course_name_with_type
          e.description entry.lecturer + "\n" + entry.course_code
          # e.location entry.location
        end
      end
    end

    cal.encode
  end
end