# frozen_string_literal: true

require "yaml"
require_relative "config"
require_relative "modpack"

module UpdateModpack
  class ModpackSelector
    CHOOSE_ANOTHER = "Choose another modpack..."

    attr_reader :prompt

    def initialize(prompt:)
      @prompt = prompt
    end

    def call
      abort "error: no .mrpack files found in #{MODPACKS_DIR}" if all_names.empty?

      name = select_name
      puts "Selected modpack: #{name}"
      Modpack.new(File.join(MODPACKS_DIR, name))
    end

    def self.call(...)
      new(...).call
    end

    private

    def select_name
      return all_names.first if all_names.size == 1
      return prompt_all if featured_names.empty?

      choice = prompt.select("Select a modpack to apply:", [*featured_names, CHOOSE_ANOTHER])
      (choice == CHOOSE_ANOTHER) ? prompt_all : choice
    end

    def prompt_all
      prompt.select("Select a modpack to apply:", all_names)
    end

    def all_names
      @all_names ||= Dir.glob(File.join(MODPACKS_DIR, "*.mrpack")).map { File.basename(it) }.sort
    end

    def featured_names
      @featured_names ||= begin
        compose_path = File.join(REPO_DIR, "docker-compose.yml")
        return [] unless File.exist?(compose_path)

        compose = YAML.safe_load_file(compose_path, aliases: true)
        services = compose["services"] || {}

        services.values
          .filter_map { it.dig("environment", "MODRINTH_MODPACK") }
          .map { File.basename(it) }
          .select { all_names.include?(it) }
          .sort
      end
    end
  end
end
