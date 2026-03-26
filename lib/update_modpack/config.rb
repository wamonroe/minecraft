# frozen_string_literal: true

module UpdateModpack
  REPO_DIR = File.expand_path("../..", __dir__)
  MODPACKS_DIR = File.join(REPO_DIR, "modpacks")
  PROFILES_DIR = if ENV.key?("WSL_DISTRO_NAME")
    # requires `setx WSLENV USERPROFILE/up`
    File.join(ENV["USERPROFILE"], "AppData/Roaming/ModrinthApp/profiles")
  else
    File.expand_path("~/Library/Application Support/ModrinthApp/profiles")
  end
  MANAGED_DIRS = %w[mods resourcepacks shaderpacks].freeze
end
