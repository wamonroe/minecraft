# frozen_string_literal: true

require "update_modpack/modpack"

RSpec.describe UpdateModpack::Modpack do
  subject(:modpack) { described_class.new("/packs/Adventurecraft 26.2.0.mrpack") }

  describe "#name" do
    it "returns the filename" do
      expect(modpack.name).to eq("Adventurecraft 26.2.0.mrpack")
    end
  end

  describe "#path" do
    it "returns the full path" do
      expect(modpack.path).to eq("/packs/Adventurecraft 26.2.0.mrpack")
    end
  end
end
