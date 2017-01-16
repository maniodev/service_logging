require "spec_helper"

RSpec.describe ServiceLogging::AppendInfoToPayload do
  let(:payload) { {} }

  let(:request_body) { '{"type":"request"}' }
  let(:response_body) { '{"type":"response"}' }
  let(:request_headers) { { "HTTP_AUTHORIZATION" => "Bearer 12345678" } }
  let(:response_headers) { { "Set-Cookie" => "_session_id=1234" } }

  let(:request) { double("ActionDispatch::Request", body: StringIO.new(request_body), headers: request_headers) }
  let(:response) { double("ActionDispatch::Response", body: response_body, headers: response_headers) }

  def pretty_json(hash)
    JSON.pretty_generate(hash)
  end

  describe ".execute" do
    before do
      ServiceLogging.filters = {
        request_header_filters: ["HTTP_AUTHORIZATION"],
        response_header_filters: ["Set-Cookie"]
      }
    end

    it "fills payload" do
      described_class.execute(payload, request, response)

      expect(payload[:request_body]).to eq pretty_json(type: "request")
      expect(payload[:response_body]).to eq pretty_json(type: "response")
      expect(payload[:request_headers]).to eq '{"HTTP_AUTHORIZATION":"************678"}'
      expect(payload[:response_headers]).to eq '{"Set-Cookie":"*************234"}'
    end

    context "when invalid request and response bodies" do
      let(:request_body) { "{reques" }
      let(:response_body) { "response}" }

      it "fills them as they are" do
        described_class.execute(payload, request, response)

        expect(payload[:request_body]).to eq request_body
        expect(payload[:response_body]).to eq response_body
      end
    end
  end
end
