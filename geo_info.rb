class GeoInfo

  #
  # in realy I would check if arrays are supplied and they #respond_to? desired methods
  #
  # Example:
  #
  #  GeoInfo.timezone_services = [ Geonames.new, Earthtools.new ]
  #  GeoInfo.location_services = [ Geonames.new, Earthtools.new ]
  #
  #  info = GeoInfo.new
  #
  cattr_accessor :timezone_services, :location_services
  
  attr_accessor :longitude, :latitude, :time_zone, :search, :raw, :service

  private :new
  
  def initialize(params)
    params.each { |k,v| instance_variable_set("@#{k}", v) }  
    Rails.logger.debug self.to_s("\t\t")
  end

  def self.lookup_location(zip, city, country, options = {})
    Rails.logger.debug "\t1) Determine location based on zip, city, country"

    @location_services.responsibility_chain do |service|
      service.lookup_location(zip, city, country, options)          
    end
  end

  def lookup_time_zone(latitude, longitude, options = {})
    Rails.logger.debug "\n\t2) Determine time zone based on longitude/latitude"

    # Returns first block returning non-zero
    # see ./ext/responsibility_chain.rb
    @timezone_services.responsibility_chain do |service|
      service.lookup_time_zone( latitude, longitude, options)      
    end
  end
  
  
  def to_s(prefix)
    output = prefix + "Geo info:"

    self.instance_variables.each do |var|
      output << prefix
      output << "- #{var}: \t#{self.instance_variable_get(var).inspect}\n"
    end
    
    output
  end
 
end
