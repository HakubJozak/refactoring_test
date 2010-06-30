module Services
  #
  # Include this module if you want to implement new service
  # translating geo coordinates to timezone compatible with Rails.
  # Expects #lookup_offset_and_timezone_id to be implemented by including class.
  #
  module TimezoneService

    #
    # Tranlating geo coordinates to timezone compatible with Rails.
    #
    def lookup_time_zone(latitude, longitude, options = {})
      tz = lookup_offset_and_timezone_id!(latitude, longitude)
      tz.guess_rails_timezone!
      
      Rails.logger.debug "\tTime zone info:"
      Rails.logger.debug "\t- Time zone id: #{tz.timezone_id}"
      Rails.logger.debug "\t- Raw offset: #{tz.raw_offset}"
      Rails.logger.debug "\t- ActiveSupport: #{tz.active_support}"

      tz
    end
    
    def to_s
      self.class.to_s
    end
    
  end
end
