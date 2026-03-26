# frozen_string_literal: true

require_relative "config"
require_relative "profile"

module UpdateModpack
  class ProfileSelector
    CHOOSE_ANOTHER = "Choose another profile..."

    attr_reader :prompt, :modpack

    def initialize(prompt:, modpack:)
      @prompt = prompt
      @modpack = modpack
    end

    def call
      abort "error: profiles directory not found: #{PROFILES_DIR}" unless Dir.exist?(PROFILES_DIR)
      abort "error: no profiles found in #{PROFILES_DIR}" if all_names.empty?

      name = select_name
      puts "Selected profile: #{name}"
      Profile.new(name)
    end

    def self.call(...)
      new(...).call
    end

    private

    def select_name
      return prompt_all if suggested_names.empty?

      choice = prompt.select("Select a local profile to update:", [*suggested_names, CHOOSE_ANOTHER])
      (choice == CHOOSE_ANOTHER) ? prompt_all : choice
    end

    def prompt_all
      prompt.select("Select a local profile to update:", all_names)
    end

    def all_names
      @all_names ||= Dir.glob(File.join(PROFILES_DIR, "*"))
        .select { File.directory?(it) }
        .map { File.basename(it) }
        .sort
    end

    def suggested_names
      @suggested_names ||= all_names.select { it.start_with?(modpack_base_name) }
    end

    def modpack_base_name
      # Strip trailing " VERSION.mrpack", e.g. "Adventurecraft 26.2.0.mrpack" → "Adventurecraft"
      modpack.name.sub(/\s+\d[\d.]*\.mrpack$/, "")
    end
  end
end
