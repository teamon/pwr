require "icalendar"
require "lib/ecl_date"

Dir[File.dirname(__FILE__) + "/../semesters/*.rb"].each {|f| require f }

class ICalGenerator
  include Icalendar

  def self.generate!(schedule)
    cal = Calendar.new
    
    EclDate.semesters[schedule.year][schedule.semester].dates.each do |date|
      schedule.days[date.wday-1].entries.select {|e| e.in_week?(date.cweek) }.each do |entry|
        cal.event do
          dtstart DateTime.civil(date.year, date.month, date.day, entry.start_hour, entry.start_min)
          dtend   DateTime.civil(date.year, date.month, date.day, entry.end_hour, entry.end_min)
          summary entry.course_name_with_type
          description entry.lecturer + "\n" + entry.course_code
          location "C-13 / 0.45"
        end
      end
    end

    cal.to_ical
  end
end