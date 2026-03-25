# Family Minecraft Servers

This repo is how I run Minecraft servers for my family. Nothing fancy — just a Docker Compose setup
that keeps things running reliably, backed up automatically, and accessible without everyone needing
to remember a weird port number.

## How it works

Everything runs in Docker using a handful of great images from [itzg](https://github.com/itzg):

- **[itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server)** — runs the actual
  Minecraft servers, loading modpacks directly from Modrinth `.mrpack` files.
- **[itzg/mc-router](https://github.com/itzg/mc-router)** — routes incoming connections on port
  25565 to the right server based on the hostname, so multiple servers can share a single external
  port.
- **[itzg/mc-backup](https://github.com/itzg/docker-mc-backup)** — handles automatic backups for
  each server, pruning old ones so storage doesn't pile up.

We use [Modrinth](https://modrinth.com) to manage modpacks for both the server and the clients. The
server loads modpacks from `.mrpack` files (Modrinth's format), and everyone in the family installs
the same modpack on their client through the [Modrinth App](https://modrinth.com/app) — so the
server and clients always stay in sync. Modpack files live in the `modpacks/` directory and are
mounted into the server containers read-only. When I want to update a modpack, there's a script for
that (see below).

## Setup

### Prerequisites

- [Devbox](https://www.jetify.com/devbox) — manages the local dev environment
- [Docker](https://docs.docker.com/get-docker/) with Docker Compose

### Running the server

1. Clone this repo onto the host machine.
2. Install and setup the devbox environment:
   ```sh
   devbox install
   devbox run setup
   ```
3. Start everything:
   ```sh
   docker compose up -d
   ```

That's it. The servers will start up, mc-router will begin routing connections, and backups will run
automatically every 24 hours.

### Updating a modpack

Updating a modpack is a two-part process: first you prepare and deploy the new version to the
server, then each client updates their local Modrinth profile to match.

**Preparing the new modpack and updating the server:**

1. Update the modpack on one of the clients using the Modrinth App (add/remove mods, bump versions,
   whatever).
2. Export the updated profile from the Modrinth App as a new `.mrpack` file.
3. Add the new `.mrpack` to the `modpacks/` directory.
4. Update the `MODRINTH_MODPACK` entry in `docker-compose.yml` for the relevant server to point to
   the new file, then commit everything.
5. Restart the server:
   ```sh
   docker compose down
   docker compose up -d
   ```

**Updating each client:**

Once the server is running the new modpack, everyone else needs to update their local Modrinth
profile. On each client machine:

1. Make sure devbox is installed and set up (run `devbox install` and `devbox run setup` if needed).
2. Run the update script:
   ```sh
   devbox run update-modpack
   ```
3. When prompted, select the new modpack and choose the destination profile to update.

## License

[MIT](LICENSE)
