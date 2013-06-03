require 'spec_helper'

describe Fql::Query do
  describe :compose do
    it "composes single queries" do
      result = described_class.new("SELECT name FROM user WHERE uid=me()").compose
      result.should eq "SELECT name FROM user WHERE uid=me()"
    end

    it "composes single queries with newlines" do
      result = described_class.new("SELECT name FROM \r\nuser WHERE\r\n uid=me()").compose
      result.should eq "SELECT name FROM user WHERE uid=me()"
    end

    it "composes multi queries" do
      query = { all_friends: "SELECT uid2 FROM friend WHERE uid1=me()",
                my_name: "SELECT name FROM user WHERE uid=me()" }
      result = described_class.new(query).compose
      result.should eq "{\"all_friends\":\"SELECT uid2 FROM friend WHERE uid1=me()\",\"my_name\":\"SELECT name FROM user WHERE uid=me()\"}"
    end

    it "composes multi queries with newlines" do
      query = { all_friends: "SELECT\n uid2 FROM friend \rWHERE uid1=me()",
                my_name: "SELECT\r\n name FROM user WHERE uid=me()" }
      result = described_class.new(query).compose
      result.should eq "{\"all_friends\":\"SELECT uid2 FROM friend WHERE uid1=me()\",\"my_name\":\"SELECT name FROM user WHERE uid=me()\"}"
    end
  end # :compose
end
