# frozen_string_literal: true

require "fileutils"

module UpdateModpack
  module Update
    class OverrideApplier
      attr_reader :overrides_dir, :profile_dir, :prompt

      def initialize(overrides_dir:, profile_dir:, prompt:)
        @overrides_dir = overrides_dir
        @profile_dir = profile_dir
        @prompt = prompt
      end

      def call
        return unless Dir.exist?(overrides_dir)

        puts
        if prompt.yes?("Apply overrides (keybindings, config, etc.)?", default: false)
          apply_overrides
        else
          puts "Skipping overrides."
        end
      end

      def self.call(...)
        new(...).call
      end

      private

      def apply_overrides
        puts "Applying overrides..."
        Dir.children(overrides_dir).each do |child|
          src = File.join(overrides_dir, child)
          dest = File.join(profile_dir, child)
          if File.directory?(src)
            puts "  Replacing #{child}/"
            FileUtils.rm_rf(dest)
            FileUtils.cp_r(src, dest)
          else
            puts "  Copying #{child}"
            FileUtils.cp(src, dest)
          end
        end
      end
    end
  end
end
