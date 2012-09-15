require "net/http"
require "fql/query"
require "fql/exception"
require "multi_json"

module Fql
  BASE_URL = 'https://graph.facebook.com/fql?q='

  def self.execute(query, options = {})
    fql_query = Fql::Query.new query
    url = make_url(fql_query, options)
    response = make_request url 
    self.decode_response response
  end

  def self.make_url(fql_query, options = {})
    url = self::BASE_URL + URI.encode(fql_query.compose)
    if options.has_key?(:access_token)
      url += "&access_token=#{options[:access_token]}"
    end
    URI.parse url
  end

  protected
  def self.make_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Get.new(uri.request_uri)
    http.request(request)
  end

  protected
  def self.decode_response(response)
    decoded_json = MultiJson.load(response.body)
    result = decoded_json["data"]
    if !result
      raise Fql::Exception.new(decoded_json)
    end
    result
  end

end
