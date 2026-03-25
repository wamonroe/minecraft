# frozen_string_literal: true

require "json"
require "fileutils"
require "zip"

Zip.warn_invalid_date = false

module UpdateModpack
  module Update
    class Extractor
      attr_reader :modpack, :work_dir

      def initialize(modpack:, work_dir:)
        @modpack = modpack
        @work_dir = work_dir
      end

      def call
        {
          files: index.fetch("files", []),
          overrides_dir: File.join(pack_dir, "overrides")
        }
      end

      def self.call(...)
        new(...).call
      end

      private

      def unzip
        FileUtils.mkdir_p(pack_dir)
        Zip::File.open(modpack.path) do |zip|
          zip.each do |entry|
            dest = File.join(pack_dir, entry.name)
            FileUtils.mkdir_p(entry.directory? ? dest : File.dirname(dest))
            entry.extract(destination_directory: pack_dir) { true }
            File.chmod(entry.directory? ? 0o755 : 0o644, dest)
          end
        end
      rescue Zip::Error => e
        raise "failed to extract #{modpack.name}: #{e.message}"
      end

      def index
        return @index if defined?(@index)

        unzip
        raise "modrinth.index.json not found in pack" unless File.exist?(index_path)

        @index = JSON.parse(File.read(index_path))
      end

      def pack_dir
        @pack_dir ||= File.join(work_dir, "pack")
      end

      def index_path
        File.join(pack_dir, "modrinth.index.json")
      end
    end
  end
end
