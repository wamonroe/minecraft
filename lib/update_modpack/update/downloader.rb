# frozen_string_literal: true

require "fileutils"
require "net/http"
require "uri"

module UpdateModpack
  module Update
    class Downloader
      attr_reader :files, :profile_dir

      def initialize(files:, profile_dir:)
        @files = files
        @profile_dir = profile_dir
      end

      def call
        puts "\nDownloading files..."
        return puts "  No files listed in index." if files.empty?

        failures = files.filter_map { |entry| download_entry(entry) }
        report(failures)
      end

      def self.call(...)
        new(...).call
      end

      private

      def download_entry(entry)
        rel_path = entry["path"]
        url = entry.fetch("downloads", []).first

        return skip(rel_path) unless url

        write_file(url, rel_path)
      end

      def skip(rel_path)
        puts "  SKIP (no download URL): #{rel_path}"
        nil
      end

      def write_file(url, rel_path)
        dest = File.join(profile_dir, rel_path)
        FileUtils.mkdir_p(File.dirname(dest))
        print "  #{rel_path}... "
        fetch(url, dest)
        puts "done"
        nil
      rescue => e
        puts "FAILED: #{e.message}"
        rel_path
      end

      def report(failures)
        if failures.any?
          warn "\nWarning: #{failures.size} file(s) failed to download:"
          failures.each { warn "  - #{it}" }
          exit 1
        else
          puts "\nAll #{files.size} file(s) downloaded successfully."
        end
      end

      def fetch(url, dest)
        uri = URI.parse(url)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
          File.binwrite(dest, http.get(uri.request_uri).body)
        end
      end
    end
  end
end
