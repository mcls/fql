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
    #   options = { :access_token => "fb_access_token" }
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

    # Constructs the Facebook url which will return the results from the FQL
    # query. The FQL query and optional access_token are passed as GET
    # parameters.
    #
    def make_url(fql_query, options = {})
      url = self::BASE_URL + URI.encode(fql_query.compose)
      url += URI.encode("&access_token=#{options[:access_token]}") if options && options[:access_token]
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
