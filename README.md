# Hacklet Remote

Do you want to?

* Turn your lights on when the sunsets?
* Turn your AC off by sending an SMS?
* Schedule your watering system using Google Calendar?

Now you can by using Hacklet Remote, a server which connects your
[Modlets] to [IFTTT]. Which means you can leverage the full power of
IFTTT and create any recipe that it supports.

If you haven't heard of the Modlet before, it's a smart outlet cover
which allows you to convert any outlet in your house into a smart
outlet. This means that you can control whether a plug is on or off and
you can also determine how much energy it's using.

There are alot of other similar products but this is the first one that
I've seen that [costs $50][amazon] and includes control as well as
monitoring of the both sockets independently.

## Getting Started

You'll need a modlet starter pack and a computer running Linux to get started.

```shell
# Checkout a copy of the server
git clone http://github.com/mcolyer/hacklet-remote.git

# Install the required dependencies
cd hacklet-remote; bundle

# Plug in the modlet dongle to your computer

# Connect the kernel driver
sudo modprobe ftdi_sio vendor=0x0403 product=0x8c81

# Setup your modlet network
hacklet commission

# Now plug your modlet into the wall. Don't worry if you've already done
# this just press and hold the button at the top until you see the #
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
wordpress channel to send custom information.

* Title: The command you'd like to issue either 'on' or 'off'. All other
  values will be ignored.
* Description: The JSON of specifying the network id and socket id of
  the modlet you'd like to control. Ex `{"network":"0xab12","socket":0}`

## Contributing

All contributions are welcome (bug reports, bug fixes, documentation or
new features)!  If you're looking for something to do check the [issue]
list and see if there's something already there. If you've got a new
idea, feel free to create an issue for discussion.

[IFTTT]: http://ifttt.com
[Modlets]: http://themodlet.com
[amazon]: http://www.amazon.com/ThinkEco-TE1010-Modlet-Starter-White/dp/B00AAT43OA/
[issue]: https://github.com/mcolyer/hacklet-remote/issues
