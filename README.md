# AppleShove [![Code Climate](https://codeclimate.com/github/tboyko/apple_shove.png)](https://codeclimate.com/github/tboyko/apple_shove)

APN Service Provider. More powerful than a push...

## Installation

Add this line to your application's Gemfile:

    gem 'apple_shove'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apple_shove

## Usage

	# bundle exec rake -T
    bundle exec rake apple_shove:run
    bundle exec rake apple_shove:start
    bundle exec rake apple_shove:stop
    bundle exec rake apple_shove:status
    bundle exec rake apple_shove:stats

### Optional Command Line Arguments

    log_dir:          specify an absolute path if you want to log
    pid_dir:          specify an absolute or relative path where the PID file 
                      is to be stored. Defaults to the current directory.
    connection_limit: maximum number of simultaneous connections to Apple
                      allowed.

    Example usage:

    bundle exec rake apple_shove:start connection_limit=100 log_dir=log

## TCP Keep-Alives

Apple Shove has the ability to maintain connections to Apple for long durations of time without sending a notification. These connections will generally stay open, however, intermediate NATs and firewalls may expire and close the connection prematurely. 

To combat this, Apple Shove enables keep-alive on all connections to Apple. Apple Shove is not able to set the interval between keep-alives, however, as this is generally managed by the operating system. If you are aware of a relatively short NAT or firewall timer, you can either manually shorten your OS's keep-alive timer to be shorter than the timer. As this likely breaks the portability of your code, you can alternatively change the `AppleShove::CONFIG[:reconnect_timer]` to a value less than the NAT/firewall timer. This will force Apple Shove to re-establish the SSL connection after enough idle time has passed.

For reference, we have observed the following keep-alive timeout values:

* OS X: 4 minutes, 45 seconds
* Linux: 2 hours
* WIndows: 2 hours

Apple also seems to send a keep-alive packet if it sees the connection as idle for 10 minutes.

## Gotchas

Due to the TCP/IP stack, AppleShove will only know about a broken pipe to APNS after it writes two notifications to the socket. When this occurs, AppleShove will re-transmit the first as well as the second notification. Because time may have elapsed between the first and second notification writes, a non-trivial delay in the delivery of the first notification may occur.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
