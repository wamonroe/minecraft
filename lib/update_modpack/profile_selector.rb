# frozen_string_literal: true

require_relative "config"
require_relative "profile"

module UpdateModpack
  class ProfileSelector
    attr_reader :prompt

    def initialize(prompt:)
      @prompt = prompt
    end

    def call
      abort "error: profiles directory not found: #{PROFILES_DIR}" unless Dir.exist?(PROFILES_DIR)

      names = Dir.glob(File.join(PROFILES_DIR, "*"))
        .select { File.directory?(it) }
        .map { File.basename(it) }
        .sort
      abort "error: no profiles found in #{PROFILES_DIR}" if names.empty?

      name = (names.size == 1) ? names.first : prompt.select("Select a local profile to update:", names)
      puts "Selected profile: #{name}"
      Profile.new(name)
    end

    def self.call(...)
      new(...).call
    end
  end
end
