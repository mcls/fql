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



  test "creates valid uri from fql" do
    multi_query = {
      all_friends:  "SELECT uid2 FROM friend WHERE uid1=me()",
      my_name:      "SELECT name FROM user WHERE uid=me()" }
    query = Fql::Query.create multi_query

    actual = Fql.make_url(query).request_uri
    expected =  "/fql?q="+ 
                "%7B'all_friends':" + 
                "'SELECT%20uid2%20FROM%20friend%20WHERE%20uid1=me()'," + 
                "'my_name':'SELECT%20name%20FROM%20user%20WHERE%20uid=me()'%7D"

    assert_equal expected, actual
  end

  test "execute should parse array inside 'data' key of json response " + 
       "when using single query" do
    # Mock web request
    json = '{"data":[{"uid2":"1"},{"uid2": "2"}]}'
    facebook_should_respond_with json

    # Create query
    query = Fql::Query.create({ 
      all_friends:  "SELECT uid2 FROM friend WHERE uid1=me()" })

    actual = Fql.execute(query)
    expected = ActiveSupport::JSON.decode(json)["data"]

    assert_equal expected, actual 
  end

  test "execute should parse array inside 'data' key of json response " +
       "when using multiple queries" do
    # Mock web request
    json =  '{"data":[{"name":"all_friends","fql_result_set":[' + 
            '{"uid2":"509346931"},{"uid2":"511025194"},{"uid2":"524396353"}]}' +
            ',{"name":"my_name","fql_result_set":[{"name":"Maarten Claes"}]}]}'
    facebook_should_respond_with json
    
    # Create query
    query = Fql::Query.create({ 
      all_friends:  "SELECT uid2 FROM friend WHERE uid1=me()",
      my_name:      "SELECT name FROM user WHERE uid=me()" })
    
    actual = Fql.execute(query)
    expected = ActiveSupport::JSON.decode(json)["data"]

    assert_equal expected, actual
    assert_equal expected.size, 2
  end

  test "raise a Fql::Exception when something goes wrong" do
    facebook_should_respond_with EXCEPTIONS[:oauth]

    query = Fql::Query.create({query: 'SELECT uid2 FROM friend WHERE uid1=me()'})
    assert_raise Fql::Exception do
      Fql.execute(query)
    end
  end


  def facebook_should_respond_with(body, method = :any)
    FakeWeb.register_uri(method, %r|graph\.facebook\.com|, :body => body)
  end

end
