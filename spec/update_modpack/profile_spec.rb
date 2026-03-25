# frozen_string_literal: true

require "update_modpack/profile"

RSpec.describe UpdateModpack::Profile do
  subject(:profile) { described_class.new("Adventurecraft") }

  describe "#name" do
    it "returns the profile name" do
      expect(profile.name).to eq("Adventurecraft")
    end
  end

  describe "#dir" do
    it "returns the full path under PROFILES_DIR" do
      expect(profile.dir).to eq(File.join(UpdateModpack::PROFILES_DIR, "Adventurecraft"))
    end
  end
end
