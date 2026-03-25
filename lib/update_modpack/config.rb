# frozen_string_literal: true

module UpdateModpack
  REPO_DIR = File.expand_path("../..", __dir__)
  MODPACKS_DIR = File.join(REPO_DIR, "modpacks")
  PROFILES_DIR = File.expand_path("~/Library/Application Support/ModrinthApp/profiles")
  MANAGED_DIRS = %w[mods resourcepacks shaderpacks].freeze
end
