# PIMP - Plexamp Installation Management Program
Headless plexamp is sweet and all but the updater kinda sucks... It uses sudo, requires the username 'pi', will hose your install if dependencies are not available, and offers no help with setting up node (where required versions change regularly). I have tested PIMP on a raspberry pi, a laptop and a VM, each running different distros. I make no promises, but it should at least be a little more friendly than the supplied updater.

## So what does it do?
* Checks for basic dependencies.
* Makes a best-guess on the required node version based upon module checking.
* Allows user to override defaults and the best-guess with optional arguments.
* Installs latest Plexamp if not exist.
* Checks if an updated plexamp is available & updates if so.
* Installs required node version as user. 
* Sets up a systemd service to run plexamp as user.
* Starts the service & provides details on how to access it.
* Works on more devices and distros than the default updater.

## What doesn't it do?
* Set up your access token on initial run. 
* Require root or sudo.
* Require a raspberry pi, PIOS, or 'pi' as a user name.

## Dependencies
- ```curl```
- ```jq```

## Usage
```bash
./pimp -h
╔═╗╦╔╦╗╔═╗ ══════════════════════════════════════════╗
╠═╝║║║║╠═╝  Plexamp Installation Management Program  ║
╩  ╩╩ ╩╩ ════════════════════════════════════════════╝

Usage: pimp [-h] [-d <path/to/dir>] [-n <node version>]

Optional arguments:
   -h   show this help message and exit
   -d   the directory where Plexamp should reside
   -n   the major version of Node.js required. i.e. 20
```

## Note
Relying on the default best-guess Node setup is likely to fail at some point. In such cases, you'll have to look at the release announcements and specify the required Node version as an argument with ```-n <version>```. I believe that the best solution for this would be for Plex developers to extend their version endpoint to include the Node version but that is out of my control.
