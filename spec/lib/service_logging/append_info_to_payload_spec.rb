require "spec_helper"

RSpec.describe ServiceLogging::AppendInfoToPayload do
  let(:payload) { Kiev::RequestStore.store[:payload] }

  let(:request_body) { '{"type":"request", "data":{"attributes":{"password":"bigsecret"}}}' }
  let(:response_body) { '{"type":"response", "foo": "bar"}' }
  let(:request_headers) { { "HTTP_AUTHORIZATION" => "Bearer 12345678" } }
  let(:response_headers) { { "Set-Cookie" => "_session_id=1234" } }

  let(:request) { double("ActionDispatch::Request", body: StringIO.new(request_body), headers: request_headers) }
  let(:response) { double("ActionDispatch::Response", body: response_body, headers: response_headers) }

  describe ".execute" do
    before do
      Kiev::RequestStore.store.clear
      ServiceLogging.kiev.filtered_params = %w(HTTP_AUTHORIZATION Set-Cookie password)
      ServiceLogging.kiev.ignored_params = %w(foo)
    end

    context "when ServiceLogging.enabled is true" do
      around do |example|
        old_service_logging_enability_value = ServiceLogging.enabled
        old_kiev_enability_value = ServiceLogging.kiev.enabled
        ServiceLogging.enabled = true
        ServiceLogging.kiev.enabled = true
        example.run
        ServiceLogging.enabled = old_service_logging_enability_value
        ServiceLogging.kiev.enabled = old_kiev_enability_value
      end

      it "fills payload" do
        described_class.execute(request, response)

        expect(payload[:request_body]).to eq({
          "type" => "request",
          "data" => {
            "attributes" => {
              "password" => "[FILTERED]"
            }
          }
        })
        expect(payload[:response_body]).to eq({ "type" => "response" })
        expect(payload[:request_headers]).to eq({ "HTTP_AUTHORIZATION" => "[FILTERED]" })
        expect(payload[:response_headers]).to eq({ "Set-Cookie" => "[FILTERED]" })
      end

      context "when invalid request and response bodies" do
        let(:request_body) { "{reques" }
        let(:response_body) { "response}" }

        it "fills them as they are" do
          described_class.execute(request, response)

          expect(payload[:request_body]).to eq request_body
          expect(payload[:response_body]).to eq response_body
        end
      end

      context "when ServiceLogging.kiev.enabled is false" do
        around do |example|
          old_kiev_enability_value = ServiceLogging.kiev.enabled
          ServiceLogging.kiev.enabled = false
          example.run
          ServiceLogging.kiev.enabled = old_kiev_enability_value
        end

        it "doesn't add data to payload" do
          described_class.execute(request, response)
          expect(payload).to be_nil
        end
      end
    end

    context "when ServiceLogging.enabled is false" do
      around do |example|
        old_value = ServiceLogging.enabled
        ServiceLogging.enabled = false
        example.run
        ServiceLogging.enabled = old_value
      end

      it "doesn't add data to payload" do
        described_class.execute(request, response)
        expect(payload).to be_nil
      end
    end
  end
end
