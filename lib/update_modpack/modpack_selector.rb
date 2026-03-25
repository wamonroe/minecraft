# frozen_string_literal: true

require_relative "config"
require_relative "modpack"

module UpdateModpack
  class ModpackSelector
    attr_reader :prompt

    def initialize(prompt:)
      @prompt = prompt
    end

    def call
      names = Dir.glob(File.join(MODPACKS_DIR, "*.mrpack")).map { File.basename(it) }.sort
      abort "error: no .mrpack files found in #{MODPACKS_DIR}" if names.empty?

      name = (names.size == 1) ? names.first : prompt.select("Select a modpack to apply:", names)
      puts "Selected modpack: #{name}"
      Modpack.new(File.join(MODPACKS_DIR, name))
    end

    def self.call(...)
      new(...).call
    end
  end
end
