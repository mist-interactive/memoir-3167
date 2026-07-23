FROM debian:bookworm-slim

ENV GODOT_VERSION "4.7.1"
ENV GODOT_EXPORT_TEMPLATES_DIR "/root/.local/share/godot/export_templates/${GODOT_VERSION}.stable"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates wget unzip git xz-utils libfontconfig1 && update-ca-certificates

RUN wget -O godot.zip "https://downloads.godotengine.org/?version=${GODOT_VERSION}&flavor=stable&slug=linux.x86_64.zip&platform=linux.64"
RUN unzip godot.zip && \
	mv Godot_v${GODOT_VERSION}-stable_linux.x86_64 /bin/godot && \
	rm -f godot.zip

 RUN mkdir ~/.cache && \
	mkdir -p ~/.config/godot && \
	mkdir -p $GODOT_EXPORT_TEMPLATES_DIR

RUN git clone https://github.com/mist-interactive/godot_export_templates.git godot_export_templates 
RUN cd godot_export_templates && \
	tar -xf linux_release_4_7_1.tar.xz && \
	tar -xf web_release_4_7_1.tar.xz && \
	mv linux_release.x86_64 $GODOT_EXPORT_TEMPLATES_DIR/ && \
	mv web_release $GODOT_EXPORT_TEMPLATES_DIR/
RUN rm -rf godot_export_templates

COPY . /root/memoir-3167/
COPY ./deployment/entrypoint.sh /
RUN chmod +x ./entrypoint.sh

# build cmd : godot --headless --path path_to_your_project --export-release my_export_preset_name game.exe
# build cmd : godot --headless --path path_to_your_project --export-release my_export_preset_name game.exe
#RUN godot --headless --path ~/memoir-3167 --export-release "Linux" "~/memoir-3167.bin"

# RUN godot --headless --path ~/memoir-3167 --export-release "Linux" "/root/test/memoir-3167.bin"

# CMD ["sh"]

ENTRYPOINT ["./entrypoint.sh"]
CMD ["bash"]
