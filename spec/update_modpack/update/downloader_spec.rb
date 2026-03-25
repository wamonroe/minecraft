# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "net/http"
require "update_modpack/update/downloader"

RSpec.describe UpdateModpack::Update::Downloader do
  subject(:downloader) { described_class.new(files:, profile_dir: tmp) }

  let(:tmp) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmp) }

  describe "#call" do
    context "when files is empty" do
      let(:files) { [] }

      it "prints a notice and returns without downloading" do
        expect { downloader.call }.to output(/No files listed/).to_stdout
      end
    end

    context "when an entry has no download URL" do
      let(:files) { [{"path" => "mods/sodium.jar", "downloads" => []}] }

      it "skips the entry" do
        expect { downloader.call }.to output(/SKIP/).to_stdout
      end
    end

    context "when all files download successfully" do
      let(:files) do
        [{"path" => "mods/sodium.jar", "downloads" => ["https://cdn.modrinth.com/sodium.jar"]}]
      end

      let(:http) { instance_double(Net::HTTP) }

      before do
        allow(Net::HTTP).to receive(:start).and_yield(http)
        allow(http).to receive(:get).and_return(instance_double(Net::HTTPResponse, body: "fake jar content"))
      end

      it "writes the file to the profile dir" do
        downloader.call
        expect(File.exist?(File.join(tmp, "mods/sodium.jar"))).to be true
      end

      it "prints a success summary" do
        expect { downloader.call }.to output(/1 file\(s\) downloaded successfully/).to_stdout
      end
    end

    context "when a download fails" do
      let(:files) do
        [{"path" => "mods/sodium.jar", "downloads" => ["https://cdn.modrinth.com/sodium.jar"]}]
      end

      before do
        allow(Net::HTTP).to receive(:start).and_raise("connection refused")
      end

      it "prints a failure message and exits" do
        expect { downloader.call }
          .to output(/FAILED: connection refused/).to_stdout
          .and output(/1 file\(s\) failed/).to_stderr
          .and raise_error(SystemExit)
      end
    end
  end
end
