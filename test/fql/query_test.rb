require 'test_helper'
require 'fql/query'

class FqlQueryTest < ActiveSupport::TestCase

  test "can create single query without using hash" do
    assert_nothing_raised do
      query = Fql::Query.new "SELECT uid2 FROM friend WHERE uid1=me()"
      query.compose
    end
  end


  test 'multiquery gets composed properly' do
    multi_query = {
      all_friends:  "SELECT uid2 FROM friend WHERE uid1=me()",
      my_name:      "SELECT name FROM user WHERE uid=me()"
    }
    query = Fql::Query.new multi_query

    actual = query.compose
    expected =  "{" +
      "'all_friends':'SELECT uid2 FROM friend WHERE uid1=me()'," +
      "'my_name':'SELECT name FROM user WHERE uid=me()'" +
    "}"

    assert_equal expected, actual
  end

  test 'single query gets composed properly' do
    query = Fql::Query.new "SELECT name FROM user WHERE uid=me()"
    actual   = query.compose
    expected = "SELECT name FROM user WHERE uid=me()"
    assert_equal expected, actual
  end
end
