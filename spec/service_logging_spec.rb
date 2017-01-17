require "spec_helper"

RSpec.describe ServiceLogging do
  describe ".setup" do
    let(:app) { ActiveSupport::OrderedOptions.new }

    before do
      app.config = ActiveSupport::OrderedOptions.new
      app.config.lograge = ActiveSupport::OrderedOptions.new
      app.config.service_logging = ActiveSupport::OrderedOptions.new
    end

    it "sets the default lograge options" do
      described_class.setup(app)

      expect(described_class.enabled).to eq(true)

      expect(app.config.lograge.enabled).to eq(true)
      expect(app.config.lograge.formatter).to be_instance_of(Lograge::Formatters::Logstash)
      expect(app.config.lograge.custom_options).to be_instance_of(Proc)
    end

    it "sets custom defined lograge options" do
      app.config.service_logging.lograge = ActiveSupport::OrderedOptions.new
      app.config.service_logging.lograge.ignore_actions = %w(SomeController#action)

      described_class.setup(app)

      expect(app.config.lograge.ignore_actions).to eq(%w(SomeController#action))
    end

    describe "service_logging.filters" do
      before do
        app.config.service_logging.filters = filters

        described_class.setup(app)
      end

      context "when service_logging.filters is set" do
        let(:filters) { { foo: "bar" } }

        it "uses service_logging.filters value" do
          expect(described_class.filters).to eq(filters)
        end
      end

      context "when service_logging.filters is NOT set" do
        let(:filters) { nil }

        it "initializes filters" do
          expect(described_class.filters).to eq({})
        end
      end
    end

    describe "service_logging.log_level" do
      before do
        app.config.service_logging.log_level = log_level

        described_class.setup(app)
      end

      context "when service_logging.log_level is set" do
        let(:log_level) { :error }

        it "sets lograge.log_level to be equal to service_logging.log_level" do
          expect(app.config.lograge.log_level).to eq(:error)
        end
      end

      context "when service_logging.log_level is NOT set" do
        let(:log_level) { nil }

        it "does not change lograge.log_level" do
          expect(app.config.lograge.log_level).to be_nil
        end
      end
    end
  end
end
