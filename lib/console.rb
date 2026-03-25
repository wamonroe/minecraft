# frozen_string_literal: true

require "bundler/setup"
require "tty-prompt"

PROMPT = TTY::Prompt.new(interrupt: :exit)

all_services = `docker compose config --services`.split
services = all_services.reject { |s| s == "mc_router" || s.start_with?("backup_") }.sort

abort "error: no game servers found in docker-compose.yml" if services.empty?

service = (services.size == 1) ? services.first : PROMPT.select("Select a server:", services)

exec "docker", "compose", "exec", "-i", service, "rcon-cli"
