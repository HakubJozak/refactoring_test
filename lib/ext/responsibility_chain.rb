class Array
  def responsibility_chain(&block)
    each do |service|
      Rails.logger.debug "\tTrying #{service} ..."

      result = begin
                 block.yield
               rescue => e
                 # TODO - log it correctly
                 nil
               end

      return result if result
    end   
  end

end
