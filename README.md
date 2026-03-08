A simple, lightweight and costomisable BASH script to update and clean pacman, yay and flatpak.
Updates pacman, yay and flatpak, removes orphan libraries, clears cache, checks system integrity and reboots
When you run it, you'll need to select what you want to do. Press 1 twice to do everything
To disable color, system integrity, rebooting and all other options, check the start of the script

Installation:
git clone https://github.com/oscarfbruce-arch/Bash-Cleanup
cd Bash-Cleanup
sudo chmod +x cleanup.sh

Run in Bash-Cleanup with
./cleanup.sh

To make run in any directory:
sudo cp cleanup.sh /usr/local/bin

And then in any directory run with:
cleanup.sh
