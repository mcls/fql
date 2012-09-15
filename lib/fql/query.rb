module Fql
  class Query

    def initialize(queries)
      if queries.is_a?(Hash)
        @queries = queries
      elsif queries.is_a?(String)
        @queries = { q: queries }
      else
        raise "Invalid Query format: has to be a String or a Hash"
      end
    end

    # Returns the query as a String which has been properly formatted and can be
    # sent to Facebook.
    def compose
      final_query = '{'
      @queries.each do |key, query|
        final_query += "'" + key.to_s + "':'" + query + "',"
      end
      final_query[0...-1] + '}' # Remove last ',' and add closing '}'
    end

  end
end
