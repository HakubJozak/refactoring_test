class Array
  def responsibility_chain(allowed_exception, &block)
    each do |service|
      Rails.logger.debug "\tTrying #{service} ..."

      result = begin
                 block.yield
               rescue allowed_exception => e
                 # TODO - log it correctly
                 nil
               end

      return result if result
    end   
  end

end
