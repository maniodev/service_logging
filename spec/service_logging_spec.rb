require "spec_helper"

RSpec.describe ServiceLogging do
  describe ".setup" do
    let(:app) { ActiveSupport::OrderedOptions.new }

    before do
      app.config = ActiveSupport::OrderedOptions.new
      app.config.service_logging = ActiveSupport::OrderedOptions.new
      app.config.service_logging.kiev = ActiveSupport::OrderedOptions.new
      app.config.service_logging.kiev.enabled = true
    end

    it "sets the default kiev options" do
      described_class.setup(app)

      expect(described_class.enabled).to eq(true)
      expect(Kiev::Config.instance.filtered_params).to eq Kiev::Config::FILTERED_PARAMS
      expect(Kiev::Config.instance.ignored_params).to eq Kiev::Config::IGNORED_PARAMS
      # does not log /health request by default
      expect(Kiev::Config::DEFAULT_LOG_REQUEST_CONDITION.call(OpenStruct.new(path: "/health"), nil)).to eq false
    end

    it "adds custom filtered params" do
      app.config.service_logging.kiev.filtered_params = %w(pin)

      described_class.setup(app)

      expect(Kiev::Config.instance.filtered_params).to eq [*Kiev::Config::FILTERED_PARAMS, "pin"]
    end

    it "adds custom filtered params" do
      app.config.service_logging.kiev.ignored_params = %w(foo)

      described_class.setup(app)

      expect(Kiev::Config.instance.ignored_params).to eq [*Kiev::Config::IGNORED_PARAMS, "foo"]
    end
  end
end
