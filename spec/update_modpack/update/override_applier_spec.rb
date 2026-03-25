# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "tty/prompt"
require "update_modpack/update/override_applier"

RSpec.describe UpdateModpack::Update::OverrideApplier do
  subject(:service) { described_class.new(overrides_dir:, profile_dir:, prompt:) }

  let(:tmp) { Dir.mktmpdir }
  let(:overrides_dir) { File.join(tmp, "overrides") }
  let(:profile_dir) { File.join(tmp, "profile") }
  let(:prompt) { instance_double(TTY::Prompt) }

  before { FileUtils.mkdir_p(profile_dir) }
  after { FileUtils.rm_rf(tmp) }

  describe "#call" do
    context "when overrides_dir does not exist" do
      it "does nothing" do
        allow(prompt).to receive(:yes?)
        service.call
        expect(prompt).not_to have_received(:yes?)
      end
    end

    context "when overrides_dir exists and the user declines" do
      before do
        FileUtils.mkdir_p(overrides_dir)
        allow(prompt).to receive(:yes?).and_return(false)
      end

      it "prints a skip message" do
        expect { service.call }.to output(/Skipping overrides/).to_stdout
      end

      it "does not copy any files" do
        File.write(File.join(overrides_dir, "options.txt"), "key=value")
        service.call
        expect(File.exist?(File.join(profile_dir, "options.txt"))).to be false
      end
    end

    context "when overrides_dir exists, user accepts, with a file override" do
      before do
        FileUtils.mkdir_p(overrides_dir)
        allow(prompt).to receive(:yes?).and_return(true)
        File.write(File.join(overrides_dir, "options.txt"), "key=value")
      end

      it "copies the file to the profile dir" do
        service.call
        expect(File.read(File.join(profile_dir, "options.txt"))).to eq("key=value")
      end
    end

    context "when overrides_dir exists, user accepts, with a directory override" do
      before do
        FileUtils.mkdir_p(overrides_dir)
        allow(prompt).to receive(:yes?).and_return(true)

        src = File.join(overrides_dir, "config")
        FileUtils.mkdir_p(src)
        File.write(File.join(src, "sodium.json"), "{}")

        # pre-existing dir in profile that should be replaced
        FileUtils.mkdir_p(File.join(profile_dir, "config"))
        File.write(File.join(profile_dir, "config", "old.json"), "old")
      end

      it "replaces the directory in the profile" do
        service.call
        expect(File.exist?(File.join(profile_dir, "config", "sodium.json"))).to be true
      end

      it "removes old contents from the replaced directory" do
        service.call
        expect(File.exist?(File.join(profile_dir, "config", "old.json"))).to be false
      end
    end
  end
end
