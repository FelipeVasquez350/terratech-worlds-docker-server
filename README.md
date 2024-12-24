# Terratech-Worlds Docker Server

## How to Run

>[!WARNING]
>YOU NEED to create these folders yourself otherwise you won't be able to see the files yourself.

`./data` here is an example but you could have all the subfolders wherever you want really.

- `terratech-worlds-save`: keeps your save files of the server, you can import here yours pre-existing ones so you can keep going (it has to be compatible with your current game version tho).
- `config/dedicated_server_config.json`: the important part is the file but here is in a folder for itself, anyway the file is the one that you can edit to change the server settings.
- `wine64`: this is the wine64 folder that the server will use to run the game, just create the folder and leave the server populate it with the necessary files.

`-p` indicates the port the server will use and the one docker is going to expose, you can change it but it has to be the same as the one in the config file.

```bash
docker run -it -p 7777:7777/udp \
  -v ./data/terratech-worlds-save:/serverdata/serverfiles/TT2/Saved/ \
  -v ./data/config/dedicated_server_config.json:/serverdata/serverfiles/dedicated_server_config.json:ro \
  -v ./data/wine64:/serverdata/wine64 \
  ghcr.io/felipevasquez350/terratech-worlds-docker-server:latest
```

or use the `docker-compose.yml` file:

```bash
docker-compose up
```

## Image Version
Every time there's going to be an update to the game, a new image will be created with the new version of the game. You can check the latest version of the game in the [releases page](

There are two major versions of the image:
- `latest`: this is the latest stable version of the game, it will be updated every time there's a new stable release.
- `beta`: this is the latest beta version of the game, it will be updated every time there's a new beta release.
- `legacy`: this is the 0.5 legacy version, this is stuck in this version and won't be updated anymore.
Unless specified, each one of these will pull the latest image of the respective version.
To specify the version you want to use, you can use the tag of the image, for example:
- `0.6.1` to use the stable version of the image
- `0.6.1-unstable-2` to use the beta version of the image (this might change based on the name the devs give it, so check before trying to pull one)

## Build

Stable
```bash
docker build -t ghcr.io/felipevasquez350/terratech-worlds-docker-server:latest .
```

Beta
```bash
docker build --build-arg BETA=true -t ghcr.io/felipevasquez350/terratech-worlds-docker-server:beta .
```
