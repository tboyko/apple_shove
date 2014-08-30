# AppleShove [![Code Climate](https://codeclimate.com/github/tboyko/apple_shove.png)](https://codeclimate.com/github/tboyko/apple_shove) [![Build Status](https://travis-ci.org/tboyko/apple_shove.png?branch=master)](https://travis-ci.org/tboyko/apple_shove)

APN Service Provider. More powerful than a push...

## Why?

A quick look at [The Ruby Toolbox](https://www.ruby-toolbox.com/search?utf8=✓&q=apns) reveals a ton of pre-existing APNS gems. Why recreate the wheel?

We needed an APNS package for use with a many-tenant MDM platform. Specifically, we needed the ability to quickly push many notifications to devices spanning across *many* push certificates.

### What about [arthurnn/apn_sender](https://github.com/arthurnn/apn_sender)?

We started here and eventually [forked](https://github.com/tboyko/apn_sender) and added MDM support. **apn_sender** keeps a persistent connection to Apple, which is great. It doesn't handle multiple certificates though, so that means we'd have to have a separate daemon process running for every single push certificate.

In fact, most APNS packages were eliminated for this reason: They weren't built with multiple-certificate handling in mind, meaning something costly would have to be instantiated for each certificate.

### What about [jeremytregunna/racoon](https://github.com/jeremytregunna/racoon)?

This gem sets out to solve multiple-certificate handling, but it fell short in two ways:

1. It requires the compilation and usage of a fork of ZMQMachine. We don't want to have to manually compile the gem and we don't want to depend on someone keeping a fork of a project maintained.
2. It assumes the bottleneck is in the building of the APNS message, not in the SSL connection setup/teardown with Apple. The gem instantiates many _workers_ for the activity of building the message to be pushed, but by default only runs a single _firehose_, which is responsible for connecting to Apple. We found the opposite to be true: the connection to Apple is the slowest part.

## How does AppleShove work?

In brief, AppleShove receives push requests from a Redis queue structure. These push requests include the APNS certificate and the payload to be pushed. A single thread called the _demultiplexer_ reads from this Redis queue and also manages a pool of connection threads to Apple. When a request is received, the _demultiplexer_ sends the request to the appropriate connection thread. If the connection thread doesn't already exist, it's created first. That's it!

For you concurrency fans out there, we are using the Actor concurrency pattern via [Celluloid](https://github.com/celluloid/celluloid).

This architecture accomplishes a few things:

1. "Caches" connections to Apple. If we've sent a notification with a particular certificate recently, we get to reuse the connection instead of having to re-establish it.
2. Allows notifications to be sent in parallel. We aren't waiting for a series of connections and disconnections to take place before we can send notification #n.
3. Simplifies our client implementation. Since each notification contains all of the information AppleShove needs to send it on it's way, we can request notifications via a single static method.

Willing to give it a try? Onward...

## Usage

### Quick Note on Certificate/Key Handling

AppleShove expects certificates and keys to be bundled together in PKCS#12 PEM format. If you want to test the validity of your PKCS#12 file, you can do something similar to this:

    apns_p12 = File.read('my_cert.p12')
    begin
        AppleShove.try_p12(apns_p12)
    rescue Exception => e
        puts "the PKCS#12 file is invalid: #{e.message}"
    else
        puts "it's valid!"
    end

If you send a notification with an invalid PKCS#12 file, the notification will fail downstream.

### Sending Notifications

Sending a notification request looks like this:

    apns_p12 = File.read('my_cert.p12')
    token    = '[device token string]'
    payload  = { mdm: '[push magic string]' } # this can also be an app notification

    AppleShove.notify p12:             apns_p12,
                      device_token:    token,
                      payload:         payload,
                      expiration_date: Time.now + 60*60, # optional expiration timestamp. defaults to one year in the future.
                      priority:        5                 # optional. defaults to 10.

Need it to be a sandbox notification?

    AppleShove.notify p12:             apns_p12,
                      device_token:    token,
                      payload:         payload,
                      sandbox:         true

### Run on target redis server

You can set redis server via config:

    AppleShove::CONFIG[:redis_server] = REDIS # REDIS is your initialized redis connection

E.g. in Rails initializer with redistogo:

    redis_url = URI.parse(ENV["REDISTOGO_URL"])
    REDIS = Redis.new(host: redis_url.host, port: redis_url.port, password: redis_url.password)
    AppleShove::CONFIG[:redis_server] = REDIS

E.g. Procfile in heroku

    apn_push: bundle exec rake apple_shove:run config=config/initializers/redis_loader.rb

### Checking the Feedback Service

We also have a feedback mechanism in place:

    tokens_array = AppleShove.feedback_tokens(apns_p12)

    # or, for the sandboxed feedback service:

    tokens_array = AppleShove.feedback_tokens(apns_p12, true)

### Running the Service

	# bundle exec rake -T
    bundle exec rake apple_shove:run    # run in the foreground
    bundle exec rake apple_shove:start  # start as a daemon
    bundle exec rake apple_shove:stop   # stop the daemon
    bundle exec rake apple_shove:status # see status of daemon
    bundle exec rake apple_shove:stats  # stats related to daemon

#### Optional Command Line Arguments

    log_dir:          specify an absolute path if you want to log
    pid_dir:          specify an absolute or relative path where the PID file
                      is to be stored. Defaults to the current directory.
    connection_limit: maximum number of simultaneous connections to Apple
                      allowed.

    Example usage:

    bundle exec rake apple_shove:start connection_limit=100 log_dir=/var/log

## Installation

If you haven't already, install redis. It's normally available via brew, apt-get, and yum, but you can also build from [source](http://redis.io/download).

Add this line to your application's Gemfile:

    gem 'apple_shove'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apple_shove

## Additional Notes

### TCP Keep-Alives

AppleShove has the ability to maintain connections to Apple for long durations of time without sending a notification. These connections will generally stay open, however, intermediate NATs and firewalls may expire and close the connection prematurely.

To combat this, AppleShove enables keep-alive on all connections to Apple. AppleShove is not able to set the interval between keep-alives however, as this is generally managed by the operating system. If you are aware of a relatively short NAT or firewall timer, you can manually shorten your OS's keep-alive timer to be shorter than the timer. As this likely breaks the portability of your code, you can alternatively change the `AppleShove::CONFIG[:reconnect_timer]` to a value less than the NAT/firewall timer. This will force AppleShove to re-establish the SSL connection after enough idle time has passed.

For reference, we have observed the following keep-alive timeout values:

* OS X: 4 minutes, 45 seconds
* Linux: 2 hours
* WIndows: 2 hours

Apple also seems to send a keep-alive packet if it sees the connection as idle for 10 minutes.

### Gotchas

Due to the TCP/IP stack, AppleShove will only know about a broken pipe to APNS after it writes two notifications to the socket. When this occurs, AppleShove will re-transmit the first as well as the second notification. Because time may have elapsed between the first and second notification writes, a non-trivial delay in the delivery of the first notification may occur.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
