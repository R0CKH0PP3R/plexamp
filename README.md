# plexamp
Headless plexamp is sweet and all but the updater kinda sucks... It uses sudo, requires the username 'pi', will hose your install if an update is not available and offers no help with setting up node (where required versions have also been known to change on minor updates). I wrote some of this while running Manjaro and needed an older version of node. I then wrote some more to get a newer version of node for PIOS. I have tested it on a raspberry pi, a laptop and a VM, each running different distros. I make no promises, but it should at least be a little more friendly than the supplied updater.

So what does it do?
* Checks for basic dependencies.
* Offers to install required node version if requirement not met. 
* Sets up a systemd service to run plexamp as user. 
* Checks if an updated plexamp is available & updates if so.
* Works on more devices and distros than the default updater.

What doesn't it do?
* Set up your access token on initial run. 
* Require root or sudo.
* Require a raspberry pi, PIOS, or 'pi' as a user name. 
    
Included is an updated service file that will also work if you intend to install node yourself - this gets edited by the updater if necessary.
No promises, no warranty. Made entirely for myself but shared after seeing plexamp users requesting more 'friendly' options. However, feel free to let me know if something doesn’t work or you have some suggestions. Just bare in mind that I’m no developer, just an enthusiast. 
