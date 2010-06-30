class EarthTools

  include TimezoneService

  protected
  
  def lookup_offset_and_timezone_id!(latitude, longitude)
    url = "http://www.earthtools.org/timezone/#{latitude}/#{longitude}"
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path)
    res = Net::HTTP.start( uri.host, uri.port ) { |http| http.request( req ) }
    
    if res.msg == 'OK' then
      doc = REXML::Document.new res.body
      doc.elements.each("timezone") do |element|
        raw_offset  = Geonames::WebService::get_element_child_float( element, 'offset' )
        return TimezoneInfo.new(nil, raw_offset, nil)        
      end
    end
    
    raise TimezoneNotFound.new('No element <timezone> found in the response')
  end

end
