class Geonames 

  include TimezoneService
  
  protected

  def lookup_offset_and_timezone_id!(latitude, longitude)
    geo_time_zone = Geonames::WebService.timezone(latitude, longitude)

    unless geo_time_zone.timezone_id.blank?
      return TimezoneInfo.new(geo_time_zone.raw_offset,  geo_time_zone.timezone_id)
    else
      raise TimezoneNotFound.new
    end    
  end 
  
end

