# frozen_string_literal: true

require "fileutils"
require_relative "../config"

module UpdateModpack
  module Update
    class ClearManagedDirs
      attr_reader :profile

      def initialize(profile:)
        @profile = profile
      end

      def call
        MANAGED_DIRS.each do |managed_dir|
          target = File.join(profile.dir, managed_dir)
          if Dir.exist?(target)
            puts "  Removing contents of #{managed_dir}/"
            FileUtils.rm_rf(Dir.glob("#{target}/*"))
          else
            puts "  Creating #{managed_dir}/"
            FileUtils.mkdir_p(target)
          end
        end
      end

      def self.call(...)
        new(...).call
      end
    end
  end
end
