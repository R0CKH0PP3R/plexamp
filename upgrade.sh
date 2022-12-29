#!/bin/bash
# This script expands upon Plexamp's included updater, allowing for easier use on a wider range of systems.
cd $HOME

# What Node version is required?
NODE_RQD=16

# Check for missing requirements.
MISSING=0
[ ! -f /usr/bin/curl ] && MISSING=$((MISSING+1))
[ ! -f /usr/bin/jq ] && MISSING=$((MISSING+2))
case $MISSING in
    0) echo "Base requirements satisfied :)" ;;
    1) echo "Use your package manager to install curl before continuing." && exit 1 ;;
    2) echo "Use your package manager to install jq before continuing." && exit 1 ;;
    3) echo "Use your package manager to install curl and jq before continuing." && exit 1 ;; 
esac

# Check node version & offer to install if requirement not met.
NODE_VSN=$(node -v | cut -c 2-3)
if [ "$NODE_VSN" != "$NODE_RQD" ]; then
    echo "node version ${NODE_RQD} required but '${NODE_VSN}' found."
    echo "Press 1 to install the required version or 2 to quit and do it yourself."
    read -n1 ANS1
    if [ $ANS1 -lt 2 ]; then 
        # Download, install & load Node Version Manager.
        # PIOS sets XDG_CONFIG_HOME which will be inconsistent with many other distros. 
        # So we have to create & specify the directory for consistency.
        [ -d ".nvm" ] || mkdir .nvm 
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | NVM_DIR=.nvm bash
        [ -s ".nvm/nvm.sh" ] && \. ".nvm/nvm.sh"
        # Install required node version & modify the service accordingly
        nvm install $NODE_RQD && NODE_NEW=$(node -v) && NODE_PTH=".nvm/versions/node/${NODE_NEW}/bin/node"
        if [ $? -eq 0 ]; then
            sed -i "s|^ExecStart=.*|ExecStart=%h/${NODE_PTH} %h/plexamp/js/index.js|" plexamp/plexamp.service
            cp plexamp/plexamp.service .config/systemd/user/ && systemctl --user daemon-reload
            [ $? -eq 0 ] && echo "node ${NODE_RQD} installed :)"
            echo "If you've not yet set up your access token, then remember to do so."
        else
            echo "Something went wrong while installing node ${NODE_RQD} :(" && exit 1
        fi
    else
        exit 0
    fi
fi

# Now to get on with the upgrade.
# First, check what version we have. If that hasn't been set, we assume the latest version & set it up.
CURRENT_VSN=$(cat plexamp/version | sed -e 's/\.//g')
LATEST_VSN=$(curl -s "https://plexamp.plex.tv/headless/version$1.json" | jq -r '.latestVersion' | sed -e 's/\.//g')
if [ -z $CURRENT_VSN ]; then 
    echo $LATEST_VSN > plexamp/version
    # Check user dirs, install & start service
    [ ! -d .config/systemd/user ] && mkdir -p .config/systemd/user
    cp plexamp/plexamp.service .config/systemd/user/ && systemctl --user daemon-reload
    systemctl --user enable --now plexamp.service && echo "All done :)" || echo "Something went wrong :("
else 
    # We're actually upgrading now.
    # Periods are already stripped, but version numbers could be 2 or 3 digits, so to sort that out:
    [[ $CURRENT_VSN -lt 100 ]] && CURRENT_VSN=$(($CURRENT_VSN*10))
    [[ $LATEST_VSN -lt 100 ]] && LATEST_VSN=$(($LATEST_VSN*10))
    # Compare to see if we need to do anyhting.
    if [ $CURRENT_VSN -lt $LATEST_VSN ]; then
        PLEXAMP_URL=$(curl -s "https://plexamp.plex.tv/headless/version.json" | jq -r '.updateUrl')
        # Download and install.
        echo "Downloading Plexamp ${LATEST_VSN}..."
        curl "$PLEXAMP_URL" -o plexamp.tar.bz2
        rm -rf plexamp.last && mv plexamp plexamp.last
        tar xfj plexamp.tar.bz2 && rm plexamp.tar.bz2
        chown -R "${USER}:${USER}" plexamp
        # Copy this script & associated service back.
        cp plexamp.last/{upgrade.sh,plexamp.service} plexamp/
        echo $LATEST_VSN > plexamp/version
        # Prefer system jackd.
        [ -f /usr/bin/jackd ] && rm plexamp/treble/*/libjack*
        # Restart service.
        systemctl --user restart plexamp && echo "All done :)" || echo "Something went wrong :("
    else
        echo "Plexamp is already up to date :)"
    fi
fi
exit 0
