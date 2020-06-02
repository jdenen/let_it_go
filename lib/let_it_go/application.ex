defmodule LetItGo.Application do
  @moduledoc """
  Under the application supervisor, we spin up processes for reading from, writing to, and
  managing Kafka topics. See `LetItGo.TopicCreator` and `LetItGo.KafkaWriter` module docs
  to learn more about writing to and managing topics.

  We spin up group consumer processes under an `Elsa.Supervisor` with the `{Elsa.Supervisor, ...}`
  tuple below. The `:connection` configuration value is used to namespace processes and registries
  for this particular set of Kafka infrastructure. We stand up another `:connection` namespace to
  write to Kafka elsewhere, but both reading/writing could use the same namespace.

  Consumer group configuration (under `:group_consumer`) allows you to customize the group name
  (`:group`), a list of topics to read from (`:topics`), a process to forward read messages to
  (`:handler`) and the initial configuration of that handler process (`:handler_init_args`).

  `Elsa` uses `:brod` and `:kafka_protocol` under the hood. Configuration of those two Erlang
  libraries is passed through Elsa with the `:config` field.

  ## App configuration

  Set application environment to change which Kafka brokers or topic this application is pointed at:

      config :let_it_go,
        kafka: [broker_host_name: 9999],
        topic: "custom-topic-name"

  If not set, `LetItGo` will default to working with [DivoKafka](https://hex.pm/packages/divo_kakfa).
  """
  use Application

  def start(_type, _args) do
    children = [
      LetItGo.TopicCreator,
      LetItGo.KafkaWriter,
      {
        Elsa.Supervisor,
        endpoints: Application.get_env(:let_it_go, :kafka, [localhost: 9092]),
        connection: :let_it_go_reader,
        group_consumer: [
          group: "let_it_go_arbitrary_group_name",
          topics: [Application.get_env(:let_it_go, :topic, "let-it-go-topic")],
          handler: LetItGo.MessageHandler,
          handler_init_args: [output_dir: ".output", filename: "messages"],
          config: [
            begin_offset: :earliest,
            offset_reset_policy: :reset_to_earliest,
            prefetch_count: 0,
            prefetch_bytes: 2_097_152
          ]
        ]
      }
    ]

    opts = [strategy: :one_for_one, name: LetItGo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
