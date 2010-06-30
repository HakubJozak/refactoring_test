#
# Include this module if you want to implement new service
# translating geo coordinates to timezone compatible with Rails.
# Expects #lookup_offset_and_timezone_id to be implemented by including class.
#
module TimezoneService

  class TimezoneNotFound < Exception;  end
  
  #
  # Tranlating geo coordinates to timezone compatible with Rails.
  #
  def lookup_time_zone(latitude, longitude, options = {})
    raw_offset, timezone_id = lookup_offset_and_timezone_id(latitude, longitude)

    Rails.logger.debug "\tTime zone info:"
    Rails.logger.debug "\t- Time zone id: #{timezone_id}"
    Rails.logger.debug "\t- Raw offset: #{raw_offset}"

    timezone = guess_rails_timezone(raw_offset, timezone_id)
    
    Rails.logger.debug "\t- ActiveSupport::TimeZone: #{time_zone.name}"
    return {:active_support => time_zone, :raw => {:offset => raw_offset, :time_zone_id => timezone_id}}

  rescue TimezoneNotFound => e
    Rails.logger.debug "\tCould not determine time zone#{e}"
    return nil
  end

  def to_s
    self.class.to_s
  end
  

  protected
  
  def guess_rails_timezone(raw_offset, timezone_id)
    # Check if the time zone identifier is according to the rails identifiers
    time_zone = ActiveSupport::TimeZone[timezone_id.split('/')[1]]

    # Check if the time zone identifier is according to tz info
    # standard and translate it to rails
    time_zone ||= ActiveSupport::TimeZone::MAPPING.invert[timezone_id]

    # TODO: could do better filtering on city/country perhaps
    time_zone ||= ActiveSupport::TimeZone[raw_offset]

    unless time_zone
      raise TimeZoneNotFound.new("Rails did not translate the TZ")
    else
      time_zone
    end
  end
  
end
