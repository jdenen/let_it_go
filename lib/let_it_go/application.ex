defmodule LetItGo.Application do
  @moduledoc false

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
          topics: ["let-it-go-topic"],
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
