require 'test_helper'

class FqlTest < ActiveSupport::TestCase
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
end
