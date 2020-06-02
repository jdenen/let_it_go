# LetItGo

An example app using [elsa](https://hex.pm/packages/elsa)

## Usage

Install dependencies.

```sh
mix deps.get
```

Start Kafka with [divo](https://hex.pm/packages/divo) and [divo_kafka](https://hex.pm/packages/divo_kafka).

```sh
mix docker.start
```

At this point, you can write messages to the configured Kafka topic (default `let-it-go-topic`) by any means. `LetItGo` provides a helper function to make this easy (and demonstrate producer setup).

Drop into an `IEx` session running `LetItGo` and use `LetItGo.write/1` to produce messages. This function will accept a single string or a list of strings.

```sh
iex -S mix
```

```elixir
LetItGo.write("this is a message")
LetItGo.write(["foo", "bar", "baz"])
```

Messages will be read from Kafka and written to disk in `.output/messages`. New messages overwrite the file, because I'm lazy and it kept the code simpler.

### Reading from Kafka

See the [LetItGo.Application](lib/let_it_go/application.ex) module documentation for specifics on configuring your application to read from Kafka and handle messages.

### Writing to Kafka

See the [LetItGo.KafkaWriter](lib/let_it_go/kafka_writer.ex) module documentation for specifics on configuring your application to write to Kafka.

### Managing Kafka topics

See the [LetItGo.TopicCreator](lib/let_it_go/topic_creator.ex) module documentation for specifics on ensuring a topic exists to read from/write to.

## App configuration

By default, `LetItGo` assumes you're going to spin up a Kafka cluster in Docker with [divo](https://hex.pm/packages/divo) and use a topic named `let-it-go-topic`. But these can be overwritten in application configuration. The `:kafka` field must be a keyword list with a hostname atom key and an integer port value. The `:topic` field must be a string.

```elixir
# config/config.exs
config :let_it_go,
  kafka: [broker_host_name: 9999],
  topic: "custom-topic-name"
```
