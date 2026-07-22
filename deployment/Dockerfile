FROM debian:bookworm-slim

ENV GODOT_VERSION "3.2.1"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    unzip \
    python \
    python-openssl \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && mkdir -p ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_server.64 /usr/local/bin/godot \
    && unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && rm -f Godot_v${GODOT_VERSION}-stable_export_templates.tpz Godot_v${GODOT_VERSION}-stable_linux_server.64.zip

# build cmd : godot --headless --path path_to_your_project --export-release my_export_preset_name game.exe
RUN godot --headless --path ~/memoir-3167 --export-release "Linux" "~/memoir-3167.bin"
