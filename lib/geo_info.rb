class TimezoneNotFound < Exception;  end
class LocationNotFound < Exception;  end    


#
# Example:
#
#  GeoInfo.timezone_services = [ Geonames.new, Earthtools.new ]
#  GeoInfo.location_services = [ TZInfo.new, Geonames.new ]
#
#  info = GeoInfo.lookup_location('10100','Prague','Czech Republic')
#  info = GeoInfo.lookup_time_zone(53.2323,65.01)
#
#
class GeoInfo

  # in reality I would check if arrays are supplied and if they #respond_to? desired methods  
  cattr_accessor :timezone_services, :location_services
  
  attr_accessor :longitude, :latitude, :time_zone, :search, :service

  private :new
  
  def initialize(params = {}, &setup)
    params.each { |k,v| instance_variable_set("@#{k}", v) }  
    Rails.logger.debug self.to_s("\t\t")
    setup.yield(self) if setup
  end

  def self.lookup_location(zip, city, country, options = {})
    Rails.logger.debug "\t1) Determine location based on zip, city, country"

    @location_services.responsibility_chain(LocationNotFound) do |service|
      service.lookup_by_address!(zip, city, country, options)          
    end
  end

  def self.lookup_time_zone(latitude, longitude, options = {})
    Rails.logger.debug "\n\t2) Determine time zone based on longitude/latitude"
    # Returns first block returning non-zero
    # see ./ext/responsibility_chain.rb
    @timezone_services.responsibility_chain(TimezoneNotFound) do |service|
      service.lookup_time_zone( latitude, longitude, options)      
    end
  end
  
  
  def to_s(prefix)
    output = prefix + "GeoInfo:"

    self.instance_variables.each do |var|
      output << prefix
      output << "- #{var}: \t#{self.instance_variable_get(var).inspect}\n"
    end
    
    output
  end
 
end
