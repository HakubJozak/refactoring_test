#
# The code in this file has 2 major responsabilities:
# - return "structured" location info (lat,long) based on address information
# - return a valid ActiveSupport::TimeZone instance based on long/lat
#
# Optimize this code in any and every way you think it could be optimized. 
# The interface of the methods is allowed to change.
#
# Do not you should be able to refacter this code without getting it to run, we 
# will not validate the result on it's ability to run or not. As stated earlyer 
# we care about the "why" not as such the execution
#
#
class GeoInfo

  class << self



    def service_lookup_location(service, zip, city, country, options = {})
      geo_info_attribs = {
        :search   => {:by => :location, :zip => zip, :city => city, :country => country},
        :service  => service
      }
      geo_info = nil
      case service
      when :tzinfo
        # Rails.logger.debug "\t1) Try to get TZInfo country"
        # begin
        #   tz_country = TZInfo::Country.get(country)
        # rescue TZInfo::InvalidCountryCode
        #   tz_country = nil
        # end
        # time_zone = nil
        # if tz_country
        #   Rails.logger.debug "\t\tTZInfo country FOUND: #{tz_country.inspect}"
        #   tz_country_time_zone_identifiers = tz_country.zone_identifiers.collect{|zone| zone.split('/').last}
        #   Rails.logger.debug "\t2) Try to get TZInfo country time zone using city: #{city} => #{tz_country_time_zone_identifiers.inspect}"
        #   if tz_country_time_zone_identifiers.include?(city) then
        #     time_zone = tz_country_time_zone_identifiers[tz_country_time_zone_identifiers.index(city)]
        #     time_zone = ActiveSupport::TimeZone[time_zone]
        #     tz_country_time_zone = TZInfo::Indexes::Countries.instance_variable_get(:"@countries")[tz_country.code].zones[tz_country_time_zone_identifiers.index(city)]
        #     Rails.logger.debug "\t\tTZInfo country time zone FOUND: #{tz_country_time_zone.inspect}"
        #   elsif tz_country_time_zone_identifiers.size == 1
        #     time_zone = tz_country_time_zone_identifiers[0]
        #     time_zone = ActiveSupport::TimeZone[time_zone]
        #     tz_country_time_zone = TZInfo::Indexes::Countries.instance_variable_get(:"@countries")[tz_country.code].zones[0]
        #     Rails.logger.debug "\t\tTZInfo country time zone FOUND (only 1): #{tz_country_time_zone.inspect}"
        #   end
        # else
        #   Rails.logger.debug "\t\tTZInfo country NOT FOUND: #{country.inspect}"
        # end
        # Rails.logger.debug "\t3) Time zone found ?"
        # if time_zone
        #   Rails.logger.debug "\t\t Time zone FOUND: #{tz_country_time_zone.inspect}"
        #   geo_info_attribs[:search][:key] = :tzinfo
        #   geo_info = GeoInfo.new(geo_info_attribs.merge({
        #     :longitude    => tz_country_time_zone.longitude,
        #     :latitude     => tz_country_time_zone.latitude,
        #     :time_zone    => {
        #         :active_support => time_zone,
        #         :raw => {}
        #     },
        #     :raw          => {
        #       :country            => tz_country,
        #       :country_time_zone  => tz_country_time_zone
        #     }
        #   }))
        # else
        #   Rails.logger.debug "\t\t Time zone NOT FOUND"
        # end
        
      when :geonames
            end
          end
        end
      end
      geo_info
    end

  

end
