require 'spec_helper'

describe Fql do
  let(:subject) { described_class }
  describe :execute do
    let(:single_query) { "SELECT name FROM user WHERE uid=4" }
    let(:multi_query) do
      { query1: "SELECT uid FROM user WHERE uid=4",
        query2: "SELECT name FROM user WHERE uid IN ( SELECT uid FROM #query1 )" }
    end

    context 'without access_token' do
      it "works for single queries" do
        VCR.use_cassette('single_query') do
          results = subject.execute single_query
          results.should be_a Array
          results.length.should eq 1
          results.first["name"].should eq "Mark Zuckerberg"
        end
      end

      it "works for multi-queries" do
        VCR.use_cassette('multi_query') do
          results = subject.execute multi_query
          results.should be_a Array
          results.each do |query_result|
            query_result["name"].should be_a String
            query_result["fql_result_set"].should be_a Array
          end
        end
      end

      it "works for queries containing single quotes" do
        query = { "likes1" => "SELECT user_id FROM like WHERE post_id = '204418407569_10151239646912570'",
                  "likes2" => "SELECT user_id FROM like WHERE post_id = '204418407569_10151239646912570'" }
        VCR.use_cassette('single_quoted_query') do
          expect{ subject.execute query }.to_not raise_error(Fql::Exception)
        end
      end
    end

    context 'with invalid access_token' do
      it "returns an oauth exception" do
        VCR.use_cassette('invalid_token') do
          expect {
            subject.execute(single_query, access_token: 'invalid')
          }.to raise_error(Fql::Exception)
        end
      end
    end
  end # :execute
end
