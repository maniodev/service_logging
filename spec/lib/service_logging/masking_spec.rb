require "spec_helper"

RSpec.describe ServiceLogging::Masking do
  describe "#mask" do
    it "masks string" do
      samples = {
        ""         => "",
        "1"        => "*",
        "12"       => "**",
        "123"      => "***",
        "1234"     => "***4",
        "12345"    => "***45",
        "123456"   => "***456",
        "1234567"  => "****567",
        "12345678" => "*****678"
      }
      samples.each do |input, output|
        expect(described_class.mask(input)).to eq output
      end
    end

    it "does not override original string" do
      str = "12345"
      expect(described_class.mask(str)).to eq "***45"
      expect(str).to eq "12345"
    end

    context "when nil is passed" do
      it "returns nil" do
        expect(described_class.mask(nil)).to eq nil
      end
    end

    context "integer is passed" do
      it "converts to string and masks" do
        expect(described_class.mask(123_45)).to eq "***45"
      end
    end
  end
end
