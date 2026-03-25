# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "update_modpack/profile"
require "update_modpack/update/clear_managed_dirs"

RSpec.describe UpdateModpack::Update::ClearManagedDirs do
  subject(:service) { described_class.new(profile:) }

  let(:tmp) { Dir.mktmpdir }
  let(:profile) { instance_double(UpdateModpack::Profile, dir: tmp) }

  after { FileUtils.rm_rf(tmp) }

  describe "#call" do
    context "when a managed dir already exists" do
      before do
        dir = File.join(tmp, "mods")
        FileUtils.mkdir_p(dir)
        File.write(File.join(dir, "sodium.jar"), "old")
      end

      it "removes the contents" do
        service.call
        expect(Dir.glob("#{tmp}/mods/*")).to be_empty
      end

      it "keeps the directory itself" do
        service.call
        expect(Dir.exist?(File.join(tmp, "mods"))).to be true
      end
    end

    context "when a managed dir does not exist" do
      it "creates the directory" do
        service.call
        expect(Dir.exist?(File.join(tmp, "mods"))).to be true
      end
    end

    it "handles all managed dirs" do
      service.call
      UpdateModpack::MANAGED_DIRS.each do |dir|
        expect(Dir.exist?(File.join(tmp, dir))).to be true
      end
    end
  end
end
