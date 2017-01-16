require "spec_helper"

RSpec.describe ServiceLogging::SensitiveDataJsonFilter do
  describe "#filter_request_headers" do
    let(:filter) { described_class.new(request_header_filters: ["XHEADER"]) }
    let(:headers) { { "XHEADER" => "private", "ZHEADER" => "public" } }

    it "filters given headers" do
      result = filter.filter_request_headers(headers)
      expect(result).to eq("XHEADER" => "****ate", "ZHEADER" => "public")
    end

    it "does not change original headers" do
      filter.filter_request_headers(headers)
      expect(headers).to eq("XHEADER" => "private", "ZHEADER" => "public")
    end
  end

  describe "#filter_response_headers" do
    let(:filter) { described_class.new(response_header_filters: ["XHEADER"]) }
    let(:headers) { { "XHEADER" => "private", "ZHEADER" => "public" } }

    it "filters given headers" do
      result = filter.filter_response_headers(headers)
      expect(result).to eq("XHEADER" => "****ate", "ZHEADER" => "public")
    end

    it "does not change original headers" do
      filter.filter_response_headers(headers)
      expect(headers).to eq("XHEADER" => "private", "ZHEADER" => "public")
    end
  end

  describe "#filter_request" do
    let(:filter) { described_class.new(request_filters: ["$.key", "$.login"]) }
    let(:data) { { "login" => "Savedo", "key" => "secret", "data" => "abcd" } }
    let(:filtered_data) { { "login" => "***edo", "key" => "***ret", "data" => "abcd" } }

    context "when JSON is invalid" do
      it "returns the original" do
        result = filter.filter_request("invalid json")
        expect(result).to eq "invalid json"
      end
    end

    context "when JSON is valid" do
      it "finds elements by JsonPath and filters them" do
        result = filter.filter_request(data.to_json)
        expect(result).to eq filtered_data.to_json
      end

      it "does not change the original data" do
        original_json = data.to_json
        filter.filter_request(original_json)
        expect(original_json).to eq data.to_json
      end
    end

    context "when hash is passed" do
      it "filters elements by JsonPath" do
        result = filter.filter_request(data)
        expect(result).to eq filtered_data
      end

      it "does not change the original hash" do
        original_hash = data.dup
        filter.filter_request(original_hash)
        expect(original_hash).to eq data
      end
    end
  end

  describe "#filter_response" do
    let(:filter) { described_class.new(response_filters: ["$.token"]) }
    let(:data) { { "token" => "abcxyz", "data" => "abcd" } }
    let(:filtered_data) { { "token" => "***xyz", "data" => "abcd" } }

    context "when JSON is invalid" do
      it "returns the original param" do
        result = filter.filter_response("invalid json")
        expect(result).to eq "invalid json"
      end
    end

    context "when JSON is valid" do
      it "finds elements by JsonPath and filters them" do
        result = filter.filter_response(data.to_json)
        expect(result).to eq filtered_data.to_json
      end

      it "does not change the original data" do
        original_json = data.to_json
        filter.filter_response(original_json)
        expect(original_json).to eq data.to_json
      end
    end

    context "when hash is passed" do
      it "filters elements by JsonPath" do
        result = filter.filter_response(data)
        expect(result).to eq filtered_data
      end

      it "does not change the original hash" do
        original_hash = data.dup
        filter.filter_response(original_hash)
        expect(original_hash).to eq data
      end
    end
  end
end
