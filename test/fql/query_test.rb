require 'test_helper'
require 'fql/query'

class FqlQueryTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Class, Fql::Query
  end

  test 'multiquery gets composed properly' do
    multi_query = {
      all_friends:  "SELECT uid2 FROM friend WHERE uid1=me()",
      my_name:      "SELECT name FROM user WHERE uid=me()" }
    query = Fql::Query.create multi_query

    actual = query.compose
    expected =  "{" +
      "'all_friends':'SELECT uid2 FROM friend WHERE uid1=me()'," + 
      "'my_name':'SELECT name FROM user WHERE uid=me()'" +
    "}"

    assert_equal expected, actual
  end
end
