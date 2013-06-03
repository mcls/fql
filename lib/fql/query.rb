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
      if @queries.length > 1
        compose_multi_query
      else
        compose_single_query
      end
    end

    protected

    def escape_query(query)
      query.gsub(/(\r\n|\r|\n)/m, '')
    end

    def compose_multi_query
      q = ''
      @queries.each do |key, query|
        q += "\"#{key}\":\"#{escape_query query}\","
      end
      # Remove last ',' and add enclosing braces
      '{' + q[0...-1] + '}'
    end

    def compose_single_query
      escape_query @queries[@queries.keys[0]]
    end

  end
end
