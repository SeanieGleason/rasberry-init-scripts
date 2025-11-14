TEMP_DIR=$(mktemp -d) && \
cd $TEMP_DIR && \
yes | sudo apt-get install git && \
git config --global user.email "seanie@gleason.tech" && \
git config --global user.name "SeanieGleason"  && \
sudo ssh-keyscan github.com | sudo tee -a /home/$USER/.ssh/known_hosts > /dev/null && \
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q && \
cat ~/.ssh/id_ed25519.pub && \
read -n1 -rsp $'Press any key to continue...\n' && \
yes | git clone git@github.com:SeanieGleason/rasberry-init-scripts.git && \
cd ./rasberry-init-scripts/src/main/sh/rasberry-pi/ && \
sudo sh init.sh