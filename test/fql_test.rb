require 'test_helper'
require 'fakeweb'
require 'json'

class FqlTest < ActiveSupport::TestCase
  EXCEPTIONS = {
    oauth: '{
              "error": {
                "message": "An access token is required to request this resource.", 
                "type": "OAuthException", 
                "code": 104
              }
            }'
  }


  test "creates valid uri for fql query" do
    multi_query = {
      all_friends:  "SELECT uid2 FROM friend WHERE uid1=me()",
      my_name:      "SELECT name FROM user WHERE uid=me()" 
    }
    query = Fql::Query.new multi_query

    actual    = Fql.make_url(query).request_uri
    expected  = "/fql?q="+ 
                "%7B'all_friends':" + 
                "'SELECT%20uid2%20FROM%20friend%20WHERE%20uid1=me()'," + 
                "'my_name':'SELECT%20name%20FROM%20user%20WHERE%20uid=me()'%7D"

    assert_equal expected, actual
  end

  test "can create single query without using hash" do
    assert_nothing_raised do
      query = Fql::Query.new "SELECT uid2 FROM friend WHERE uid1=me()"
      query.compose
    end
  end

  test "should correctly parse json response when using single query" do
    query = "SELECT uid2 FROM friend WHERE uid1=me()" 
    mocked_response = '{"data":[{"uid2":"1"},{"uid2": "2"}]}'

    assert_executes_query_correctly(query, mocked_response)
  end

  test "should correctly parse json response when using multiple queries" do
    multi_query = { 
      all_friends:  "SELECT uid2 FROM friend WHERE uid1=me()",
      my_name:      "SELECT name FROM user WHERE uid=me()" 
    }
    mocked_response = '{"data":['+ 
      '{"name":"all_friends","fql_result_set":[{"uid2":"1"},{"uid2":"2"}]},' + 
      '{"name":"my_name","fql_result_set":[{"name":"Some user"}]}]}'
  
    assert_executes_query_correctly(multi_query, mocked_response)
  end

  test "raise a Fql::Exception when something goes wrong" do
    facebook_should_respond_with EXCEPTIONS[:oauth]

    assert_raise Fql::Exception do
      q = Fql::Query.new 'SELECT uid2 FROM friend WHERE uid1=me()'
      Fql.execute(q)
    end
  end

  def assert_executes_query_correctly(query, mocked_json_response)
    facebook_should_respond_with mocked_json_response
    actual    = Fql.execute(Fql::Query.new(query))
    expected  = ActiveSupport::JSON.decode(mocked_json_response)["data"]
    assert_equal expected, actual
  end

  def facebook_should_respond_with(body, method = :any)
    FakeWeb.register_uri(method, %r|graph\.facebook\.com|, :body => body)
  end

end
