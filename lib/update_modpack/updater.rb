# frozen_string_literal: true

require "tmpdir"
require_relative "update/extractor"
require_relative "update/downloader"
require_relative "update/override_applier"
require_relative "update/clear_managed_dirs"

module UpdateModpack
  class Updater
    attr_reader :pack, :profile, :prompt

    def initialize(pack:, profile:, prompt:)
      @pack = pack
      @profile = profile
      @prompt = prompt
    end

    def call
      Dir.mktmpdir do |work_dir|
        @work_dir = work_dir

        puts "\nUpdating #{pack.name}..."

        Update::ClearManagedDirs.call(profile:)
        Update::Downloader.call(files:, profile_dir: profile.dir)
        Update::OverrideApplier.call(overrides_dir:, profile_dir: profile.dir, prompt:)
      end
      puts "\nDone. Profile '#{profile.name}' updated from '#{pack.name}'."
    end

    def self.call(...)
      new(...).call
    end

    private

    attr_reader :work_dir

    def extracted
      @extracted ||= Update::Extractor.call(modpack: pack, work_dir:)
    end

    def files
      extracted[:files]
    end

    def overrides_dir
      extracted[:overrides_dir]
    end
  end
end
