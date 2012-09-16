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

    def compose_multi_query
      q = ''
      @queries.each do |key, query|
        q += "'#{key}':'#{query}',"
      end
      # Remove last ',' and add enclosing braces
      '{' + q[0...-1] + '}'
    end

    def compose_single_query
      @queries[:q]
    end

  end
end
