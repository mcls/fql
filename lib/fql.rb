require "net/http"
require "openssl"
require "fql/query"
require "fql/exception"
require "multi_json"

module Fql
  BASE_URL = 'https://graph.facebook.com/fql?q='

  class << self

    # Sends an FQL query to Facebook.
    #
    # Exampe: a single query without access_token
    #
    #   Fql.execute('SELECT first_name, last_name FROM user WHERE uid = 4')
    #
    # Exampe: a multi query with an access_token
    #
    #   options = { :access_token => "fb_access_token", :appsecret_proof => "appsecret_proof" }
    #   Fql.execute({
    #     "query1" => "SELECT uid, rsvp_status FROM event_member WHERE eid = 12345678",
    #     "query2" => "SELECT name FROM profile WHERE id IN (SELECT uid FROM #query1)"
    #   }, options)
    #
    def execute(query, options = {})
      fql_query = Fql::Query.new query
      url = make_url(fql_query, options)
      response = make_request url
      self.decode_response response
    end


    # The wrapper of execute method, to get all records using pagination
    # Pagination uses timestamp columns (relies on ORDER BY time DESC)
    # and set WHERE clause to get next portion of data
    #
    # Works only with descendence ordering
    #
    # Supports both of single and multiple queries
    #
    # Query should contain two placeholders: where and limit.
    # Paginate method will use them to modificate FQL query
    #
    # Accepted options the same, as .execute method plus:
    #   time_column: The name of column with timestamp. Default is 'time'
    #   primary_key: The name of primary key (ID) column. Default is 'id'
    #   rpp: Results per page. Default is 50. Should be lesser than Facebook limitations (different for each table). Defauls is 50
    #   until: You can set the start time for pagination. All older records will be retrived
    #
    # Example:
    #
    #   Fql.paginate('SELECT post_id, message FROM stream WHERE source_id = 1234567 %{where} ORDER BY updated_time DESC LIMIT %{limit}', {
    #       time_column: 'updated_time',
    #       primary_key: 'post_id',
    #       rpp: 30
    #   }) do |result|
    #       #process the result here
    #   end
    #
    def paginate(query, options = {})
      query = { q: query } if query.is_a? String

      time_column = options[:time_column] || 'time'
      primary_key = options[:primary_key] || 'id'
      limit = options[:rpp] || 50 # Make limit chunk

      begin
        #Make where chunk
        where = ''
        where << " and #{time_column} <= #{options[:until].to_i}" unless options[:until].blank?
        (options[:last_ids] || []).each do |v|
          where << " and #{primary_key} != '#{v}'"
        end

        #Set where and limit chunks into query
        pquery = {}
        query.each { |k,v| pquery[k] = v % {where: where, limit: limit} }

        #Make query
        results = self.execute(pquery, options)

        #Usually you need to paginate first query
        set = query.size > 1 ? results.first['fql_result_set'] : results

        unless set.blank?
          last_timestamp = set.last[time_column]
          options[:until] = last_timestamp
          #Exclude all IDs with the same timestamp from next portion of data
          ids = set.select { |v| v[time_column] == last_timestamp }.map{ |v| v[primary_key] }

          options[:last_ids] = ids

          yield results
        end
      end until set.blank?
    end

    # Constructs the Facebook url which will return the results from the FQL
    # query. The FQL query and optional access_token are passed as GET
    # parameters.
    #
    def make_url(fql_query, options = {})
      url = self::BASE_URL + URI.encode(fql_query.compose)
      url += URI.encode("&access_token=#{options[:access_token]}") if options && options[:access_token]
      url += URI.encode("&appsecret_proof=#{options[:appsecret_proof]}") if options && options[:appsecret_proof]

      URI.parse url
    end

    protected

    def make_request(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      request = Net::HTTP::Get.new(uri.request_uri)
      http.request(request)
    end

    def decode_response(response)
      decoded_json = MultiJson.load(response.body)
      result = decoded_json["data"]
      if !result
        raise Fql::Exception.new(decoded_json)
      end
      result
    end

  end

end
