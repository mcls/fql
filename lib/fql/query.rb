module Fql
  class Query
    
    protected
    def initialize(multi_query)
      if multi_query.is_a?(Hash)
        @multi_query = multi_query
      else
        @multi_query = { q: multi_query } 
      end
    end

    public
    def self.create(multi_query)
      Fql::Query.new(multi_query)
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
