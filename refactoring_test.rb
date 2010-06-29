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

    def location_services
      [:tzinfo, :geonames]
    end

    def time_zone_services
      [:geonames, :earthtools]
    end

    def self.lookup_by_location(zip, city, country, options = {})
      Rails.logger.debug "\t1) Determine location based on zip, city, country"

      services.each do |service|
        Rails.logger.debug "\tTrying #{service} ..."
        geo_info = self.service_lookup_location(service, zip, city, country, options)
        break if geo_info
      end
      
      geo_info
    end

    #
    # Tries various services to lookup the timezone with given
    # +latitude+ and +longitude+
    #
    def lookup_time_zone(latitude, longitude, options = {})
      Rails.logger.debug "\n\t2) Determine time zone based on longitude/latitude"

      time_zone = nil
      services.each do |service|
        Rails.logger.debug "\tTrying #{service} ..."
        time_zone = service.lookup_time_zone( latitude, longitude, options)
        return time_zone if time_zone
      end
    end

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
        Rails.logger.debug "\t1) Determine longitude/latitude using exact search (AND)"

        # Fix incorrect mappings used by geonames
        manual_country_translation = {
          'AX' => 'FI'
        }
        country = manual_country_translation[country] if manual_country_translation.include?(country)

        # postalcodesearch with AND => (http://ws.geonames.org/postalCodeSearch?placename=2550%20Kontich%20BE&operator=AND&maxRows=1)
        geo_query = Geonames::PostalCodeSearchCriteria.new
        geo_query.place_name = [zip, city, country].compact.reject { |s| s.strip.empty? }.join(" ")
        geo_query.max_rows = "1"
        geo_info = Geonames::WebService.postal_code_search geo_query

        if geo_info.size > 0
          geo_info_attribs[:search][:key] = :exact
          geo_info = GeoInfo.new(geo_info_attribs.merge({
            :longitude    => geo_info.first.longitude,
            :latitude     => geo_info.first.latitude,
            :raw          => geo_info.first
          }))
        else
          Rails.logger.debug "\tWARNING: No geoinfo could be found for exact search !"
          Rails.logger.debug "\t\t1.1) Determine longitude/latitude using matched search (OR)"

          # postalcodesearch with OR (http://ws.geonames.org/postalCodeSearch?placename=9999%20Kunticher%20BE&country=BE&operator=OR&maxRows=10)
          geo_query = Geonames::PostalCodeSearchCriteria.new
          geo_query.place_name = [zip, city, country].compact.reject { |s| s.strip.empty? }.join(" ")
          geo_query.country_code = country
          geo_query.is_or_operator = true
          geo_query.max_rows = "10"
          geo_info = Geonames::WebService.postal_code_search geo_query
          geo_results = []
          if geo_info.size > 0
            geo_info.each do |g|
              geo_results << {
                :longitude    => g.longitude,
                :latitude     => g.latitude,
                :raw          => g
              }
            end
          end

          if geo_results.size > 0 && geo_results.first[:raw].country_code == country
            geo_info = GeoInfo.new(geo_info_attribs.merge(geo_results.first))
            geo_info.search.merge!({:key => :matched})
          else
            Rails.logger.debug "\t\tWARNING: No geo info could be found for matched search !"
            Rails.logger.debug "\t\t1.2) Lookup country in results"

            geo_info = geo_results.select{|g| g[:raw].country_code == country}.first

            if geo_info
              geo_info = GeoInfo.new(geo_info_attribs.merge(geo_info))
              geo_info.search.merge!({:key => :matched})
            else
              Rails.logger.debug "\t\tWARNING: No geo info found in results (city or zip do not exist in country)!"
              Rails.logger.debug "\t\t1.3) Perform a global search to retrieve the time zone for the country"

              # country search (http://ws.geonames.org/search?q=9999%20Kunticher%20OM&operator=OR&country=OM&maxRows=1)
              geo_query = Geonames::ToponymSearchCriteria.new
              #geo_query.q = [zip, city, country].compact.reject { |s| s.strip.empty? }.join(" ")
              #geo_query.q = country
              geo_query.country_code = country
              #geo_query.is_or_operator = true
              geo_query.max_rows = "1"
              geo_info = Geonames::WebService.search geo_query
              geo_results = []
              if geo_info.toponyms.size > 0
                geo_info.toponyms.each do |g|
                  geo_results << {
                    :longitude    => g.longitude,
                    :latitude     => g.latitude,
                    :raw          => g
                  }
                end
              end
              geo_info = geo_results.select{|g| g[:raw].country_code == country}.first

              if geo_info
                geo_info = GeoInfo.new(geo_info_attribs.merge(geo_info))
                geo_info.search.merge!({:key => :search})
              else
                # TODO: could even try to lookup city without the country
                Rails.logger.debug "\t\tWARNING: Could not determine timezone for this event (probably none existing country code) !"
              end
            end
          end
        end
      end
      geo_info
    end

  

end
