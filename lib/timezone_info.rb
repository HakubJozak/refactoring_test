class TimezoneInfo < Struct.new(:raw_offset, :timezone_id, :active_support)

    def guess_rails_timezone!
      if timezone_id
        # Check if the time zone identifier is according to the rails identifiers
        active_support = ActiveSupport::TimeZone[timezone_id.split('/')[1]]

        # Check if the time zone identifier is according to tz info
        # standard and translate it to rails
        active_support ||= ActiveSupport::TimeZone::MAPPING.invert[timezone_id]
      end

      # TODO: could do better filtering on city/country perhaps
      active_support ||= ActiveSupport::TimeZone[raw_offset] unless raw_offset

      unless active_support
        raise TimezoneNotFound.new("Rails did not translate the TZ")
      else
        self
      end
    end
    
  
end
  
