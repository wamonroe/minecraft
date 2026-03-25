# frozen_string_literal: true

require "tmpdir"
require "json"
require "fileutils"
require "zip"
require "update_modpack/modpack"
require "update_modpack/update/extractor"

RSpec.describe UpdateModpack::Update::Extractor do
  subject(:extractor) { described_class.new(modpack:, work_dir: tmp) }

  let(:tmp) { Dir.mktmpdir }
  let(:pack_dir) { File.join(tmp, "pack") }

  after { FileUtils.rm_rf(tmp) }

  context "when the mrpack contains a valid index" do
    let(:fixture_path) { File.expand_path("../../fixtures/test.mrpack", __dir__) }
    let(:modpack) { instance_double(UpdateModpack::Modpack, name: "test.mrpack", path: fixture_path) }
    let(:index_data) { Zip::File.open(fixture_path) { |z| JSON.parse(z.read("modrinth.index.json")) } }

    describe "#call" do
      it "returns the files from the index" do
        expect(extractor.call[:files]).to eq(index_data["files"])
      end

      it "returns the overrides_dir path inside the pack dir" do
        expect(extractor.call[:overrides_dir]).to eq(File.join(pack_dir, "overrides"))
      end
    end
  end

  context "when the index has no files key" do
    let(:mrpack_path) { File.join(tmp, "no_files.mrpack") }
    let(:modpack) { instance_double(UpdateModpack::Modpack, name: "no_files.mrpack", path: mrpack_path) }

    before do
      Zip::OutputStream.open(mrpack_path) do |zip|
        zip.put_next_entry("modrinth.index.json")
        zip.write("{}")
      end
    end

    it "returns an empty files array" do
      expect(extractor.call[:files]).to eq([])
    end
  end

  context "when modrinth.index.json is missing" do
    let(:mrpack_path) { File.join(tmp, "broken.mrpack") }
    let(:modpack) { instance_double(UpdateModpack::Modpack, name: "broken.mrpack", path: mrpack_path) }

    before do
      Zip::OutputStream.open(mrpack_path) do |zip|
        zip.put_next_entry("dummy.txt")
      end
    end

    it "raises an error" do
      expect { extractor.call }.to raise_error(RuntimeError, /modrinth.index.json not found/)
    end
  end
end
