# Hacklet Remote [![Build Status](https://travis-ci.org/mcolyer/hacklet-remote.png)](https://travis-ci.org/mcolyer/hacklet-remote)

Do you want to?

* Turn your lights on when the sunsets?
* Turn your AC off by sending an SMS?
* Schedule your watering system using Google Calendar?

Now you can using hacklet-remote, a server which connects your [Modlets]
to [IFTTT]. Which means you can leverage the full power of IFTTT and
create any recipe that it supports.

hacklet-remote uses the [hacklet] library to communicate with the
Modlet.

## Getting Started

You'll need a Modlet starter pack and a computer running Linux to get started.

```shell
# On Ubuntu/Debian based Linux
sudo apt-get install libftdi1
echo 'ATTRS{idVendor}=="0403", ATTRS{idProduct}=="8c81", SUBSYSTEMS=="usb", ACTION=="add", MODE="0660", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/99-thinkeco.rules

# On OSX
brew install libftdi

# For Windows see https://github.com/mcolyer/hacklet#windows

# Checkout a copy of the server
git clone http://github.com/mcolyer/hacklet-remote.git

# Install the required dependencies
cd hacklet-remote; bundle

# Plug in the modlet dongle to your computer

# Setup your modlet network
hacklet commission

# Now plug your modlet into the wall. Don't worry if you've already done
# this just press and hold the button at the top until you see the
# spinning red indicator.

# After several seconds you should see a log message indicating the
# device id and network id, keep a copy of the network id it should look
# similar to this 0xab12

# Edit config.yml and create a unique username and password.

# Run the server
rake run

# If you have a router connecting you to the Internet you'll need to
# forward external traffic on port 80 to the computer running
# hacklet-remote on port 9292.

# Make sure the site is externally accessible, by visiting your public
# ip address. You should see the word 'hacklet', if you don't the server
# isn't correctly configured.

# Create an account of ifttt.com

# Configure the 'Wordpress' channel

# Enter your public IP address as the host and the user and password you
# configured in config.yml

# Congratulations you should now be ready to configure your first channel.
```

## Configuring your IFTTT Trigger

Since IFTTT doesn't provide a webhook, it necessary for us to use their
Wordpress channel to send custom information.

* Title: The command you'd like to issue either 'on' or 'off'. All other
  values will be ignored.
* Description: The JSON of specifying the network id (printed out during
  commissioning) and socket id (0 - top, 1 - bottom) of the Modlet you'd like to
  control. Ex `{"network":"0xab12","socket":0}`

## Contributing

All contributions are welcome (bug reports, bug fixes, documentation or
new features)! All discussion happens using [issues] so if you are
interested in contributing:

* Search to make sure an issue doesn't already exist.
* If it doesn't, create a new issue and describe your proposal.

If you're interested in following the status of the project, simply
"watch" the repository on Github and you'll receive notices about all of
the new issues.

### Contribution Workflow

* Fork the repository
* Install dependencies `bundle install`
* Create a feature branch `git checkout -b short-descriptive-name`
* Run tests `bundle exec rake`
* Write your feature (and tests)
* Run tests `bundle exec rake`
* Create a pull request

[IFTTT]: http://ifttt.com
[Modlets]: http://themodlet.com
[amazon]: http://www.amazon.com/ThinkEco-TE1010-Modlet-Starter-White/dp/B00AAT43OA/
[issue]: https://github.com/mcolyer/hacklet-remote/issues
[hacklet]: http://github.com/mcolyer/hacklet/
