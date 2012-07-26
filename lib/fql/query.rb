module Fql
  class Query
    
    def initialize(multi_query)
      if multi_query.is_a?(Hash)
        @multi_query = multi_query
      elsif multi_query.is_a?(String)
        @multi_query = { q: multi_query } 
      else
        raise "Invalid Query format: has to be a String or a Hash"
      end
    end

    def compose
      final_query = '{'
      @multi_query.each do |key, query|
        final_query += "'" + key.to_s + "':'" + query + "',"
      end
      final_query[0...-1] + '}' # Remove last ',' and add closing '}'
    end

  end
end
