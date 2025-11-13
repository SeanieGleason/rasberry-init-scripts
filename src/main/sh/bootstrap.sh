TEMP_DIR=$(mktemp -d) && \
cd $TEMP_DIR && \
yes | sudo apt-get install git && \
sudo ssh-keyscan github.com | sudo tee -a ~/.ssh/known_hosts > /dev/null \
yes | git clone git@github.com:SeanieGleason/rasberry-init-scripts.git && \
cd ./src/main/sh/rasberry-pi/init.sh
