require 'spec_helper'

describe Fql do
  describe :execute do
    context 'without access_token' do
      let(:single_query) { "SELECT name FROM user WHERE uid=4" }
      let(:multi_query) do
        { query1: "SELECT uid FROM user WHERE uid=4",
          query2: "SELECT name FROM user WHERE uid IN ( SELECT uid FROM #query1 )" }
      end

      it "works for single queries" do
        VCR.use_cassette('single_query') do
          results = described_class.execute single_query
          results.should be_a Array
          results.length.should eq 1
          results.first["name"].should eq "Mark Zuckerberg"
        end
      end

      it "works for multi-queries" do
        VCR.use_cassette('multi_query') do
          results = described_class.execute multi_query
          results.should be_a Array
          results.each do |query_result|
            query_result["name"].should be_a String
            query_result["fql_result_set"].should be_a Array
          end
        end
      end
    end
  end # :execute
end
