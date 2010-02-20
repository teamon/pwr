require "icalendar"

class ICalGenerator
  include Icalendar
  
  def self.generate!(schedule)
    cal = Calendar.new
    cal.event do
      dtstart DateTime.civil(2010, 2, 21, 9, 15)
      dtend   DateTime.civil(2010, 2, 21, 11, 00)
      summary "The name of event"
      location "C-13 / 0.45"
    end
    
    cal.to_ical
  end
end