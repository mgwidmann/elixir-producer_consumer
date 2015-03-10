ProducerConsumer
================

Install Elixir

    brew install elixir


Running tests:

    mix test


Running producer/consumer on multiple machines:

    iex --name "foo@127.0.0.1" --cookie prodcon -S mix

Be sure to replace `"foo@127.0.0.1"` with a unique name and your ip address (or leave it as 127.0.0.1 for local only connection). All running users must have the same cookie or connections will be denied.

Once the console is up, connect to other users in the network

    Node.connect :"foo@127.0.0.1"

Once connected, anyone in the cluster may type the following to kick things off:

    Manager.start
