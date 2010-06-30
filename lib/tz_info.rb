class TZInfo

  GEO_INFO_ATTRS = {
    :search   => {:by => :location, :zip => zip, :city => city, :country => country},
    :service  => service
  }.freeze


  # TODO - pass just GeoInfo instead?
  # throws LocationNotFound if no location is found
  #
  def lookup_by_address!(_zip, _city, _country, options = {})
    info = GeoInfo.new
    info.city = _city
    info.country = _country
    info.zip = _zip

    Rails.logger.debug "\t1) Try to get TZInfo country"
    country = TZInfo::Country.get(_country) 
    raise LocationNotFound.new


    Rails.logger.debug "\t\tTZInfo country FOUND: #{country.inspect}"
    identifiers = country.zone_identifiers.collect{|zone| zone.split('/').last}
    
    Rails.logger.debug "\t2) Try to get TZInfo country time zone using city: #{city} => #{identifiers.inspect}"     
    

    if identifiers.include?(city) then      
      i = identifiers[identifiers.index(city)]
      country_time_zone = TZInfo::Indexes::Countries.instance_variable_get(:"@countries")[country.code].zones[identifiers.index(city)]
      Rails.logger.debug "\t\tTZInfo country time zone FOUND: #{country_time_zone.inspect}"
    elsif not identifiers.empty?
      i = identifiers[0]
      country_time_zone = TZInfo::Indexes::Countries.instance_variable_get(:"@countries")[country.code].zones[0]
      Rails.logger.debug "\t\tTZInfo country time zone FOUND (only 1): #{country_time_zone.inspect}"
    else
      Rails.logger.debug "\t\t Time zone NOT FOUND"
      raise LocationNotFound.new
    end

    info.longitude = country_time_zone.longitude
    info.latitude = country_time_zone.latitude
    info.time_zone = TimeZoneInfo.new( time_zone, nil, ActiveSupport::TimeZone[time_zone])  
    
    Rails.logger.debug "\t\t Time zone FOUND: #{country_time_zone.inspect}"
  rescue TZInfo::InvalidCountryCode => e
    # pass the original exception
    raise LocationNotFound.new("Invalid TZInfo #{e}")
  end  
end
