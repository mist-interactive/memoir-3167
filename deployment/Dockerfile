FROM debian:bookworm-slim

ENV GODOT_VERSION "4.7.1"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates wget unzip && update-ca-certificates

RUN wget -O godot.zip "https://downloads.godotengine.org/?version=${GODOT_VERSION}&flavor=stable&slug=linux.x86_64.zip&platform=linux.64"
RUN unzip godot.zip && mv Godot_v${GODOT_VERSION}-stable_linux.x86_64 /bin/godot
RUN mkdir ~/.cache && mkdir -p ~/.config/godot mkdir -p ~/.local/share/godot/templates/${GODOT_VERSION}.stable

    # && mv Godot_v${GODOT_VERSION}-stable_linux_server.64 /usr/local/bin/godot \
    # && unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    # && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    # && rm -f Godot_v${GODOT_VERSION}-stable_export_templates.tpz Godot_v${GODOT_VERSION}-stable_linux_server.64.zip

# build cmd : godot --headless --path path_to_your_project --export-release my_export_preset_name game.exe
#RUN godot --headless --path ~/memoir-3167 --export-release "Linux" "~/memoir-3167.bin"
CMD ["sh"]
