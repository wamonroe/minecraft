# frozen_string_literal: true

require "bundler/setup"
require "tty-prompt"

require_relative "update_modpack/config"
require_relative "update_modpack/modpack"
require_relative "update_modpack/profile"
require_relative "update_modpack/modpack_selector"
require_relative "update_modpack/profile_selector"
require_relative "update_modpack/updater"

prompt = TTY::Prompt.new(interrupt: :exit)

modpack = UpdateModpack::ModpackSelector.call(prompt:)
profile = UpdateModpack::ProfileSelector.call(prompt:, modpack:)
UpdateModpack::Updater.call(modpack:, profile:, prompt:)
