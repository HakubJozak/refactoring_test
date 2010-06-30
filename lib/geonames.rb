class Geonames 

  include TimezoneService

  
  def lookup_by_address!(_zip, _city, _country, options = {})
    result   = postal_code_search(_zip, _city, _country, false)
    result ||= postal_code_search(_zip, _city, _country, true)
    result ||= toponomy_search( _country, true)
    raise LocationNotFound.new unless result
    
    geo_info = GeoInfo.new do |info|
      info.longitude = result.longitude
      info.latitude = result.latitude
    end
  end


  protected

  def lookup_offset_and_timezone_id!(latitude, longitude)
    geo_time_zone = Geonames::WebService.timezone(latitude, longitude)

    unless geo_time_zone.timezone_id.blank?
      return TimezoneInfo.new(geo_time_zone.raw_offset,  geo_time_zone.timezone_id, nil)
    else
      raise TimezoneNotFound.new
    end    
  end


  #
  # postalcodesearch with AND =>
  # (http://ws.geonames.org/postalCodeSearch?placename=2550%20Kontich%20BE&operator=AND&maxRows=1)
  #
  # postalcodesearch with OR
  # (http://ws.geonames.org/postalCodeSearch?placename=9999%20Kunticher%20BE&country=BE&operator=OR&maxRows=10)
  #
  def postal_code_search(_zip, _city, _country, or_search)
    unless or_search
      Rails.logger.debug "\t1) Determine longitude/latitude using exact search (AND)"  
    else
      Rails.logger.debug "\t\t1.1) Determine longitude/latitude using matched search (OR)"
    end
    
    geo_query = Geonames::PostalCodeSearchCriteria.new
    geo_query.place_name = [zip, city, correct(country)].compact.reject { |s| s.strip.empty? }.join(" ")
    geo_query.max_rows = or_search ? '10' : '1'
    geo_query.is_or_operator = or_search
    
    results = Geonames::WebService.postal_code_search(geo_query)
    ensure_it_fits(results, _country)
  end

  def toponomy_search(_country)
    # country search (http://ws.geonames.org/search?q=9999%20Kunticher%20OM&operator=OR&country=OM&maxRows=1)
    geo_query = Geonames::ToponymSearchCriteria.new
    geo_query.country_code = country
    geo_query.max_rows = "1"
    results = Geonames::WebService.search(geo_query)
    ensure_it_fits(results, _country)    
  end
  
  private

  def ensure_it_fits(results, country)
    results.select{ |r| r.country_code == country }.first    
  end


  MAPPING_FIX = { 'AX' => 'FI' }.freeze

  # Fix incorrect mappings used by Geonames
  def correct(country)
    MAPPING_FIX[country] || country
  end


end

