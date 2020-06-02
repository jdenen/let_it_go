defmodule LetItGo.KafkaWriter do
  @moduledoc """
  We spin up Kafka producer processes under an `Elsa.Supervisor` with the `Esla.Supervisor.start_link/1`
  call in `init/1`. The `:connection` configuration field is used to namespace processes and registries
  for this particular set of Kafka infrastructure.

  Producer configuration (under `:producer`) allows you to customize the topic being written to (`:topic`).

  ## App configuration

  Set application environment to change which Kafka brokers or topic this code is pointed at:

      config :let_it_go,
        kafka: [broker_host_name: 9999],
        topic: "custom-topic-name"

  If not set, `LetItGo` will default to working with [DivoKafka](https://hex.pm/packages/divo_kafka).
  """
  use GenServer

  @doc """
  Use `LetItGo.write/1 instead of this.`
  """
  def write(messages) do
    GenServer.cast(__MODULE__, {:write, messages})
  end

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    with conn <- :let_it_go_writer,
         topic <- Application.get_env(:let_it_go, :topic, "let-it-go-topic"),
         kafka <- Application.get_env(:let_it_go, :kafka, localhost: 9092),
         {:ok, pid} <-
           Elsa.Supervisor.start_link(
             connection: conn,
             endpoints: kafka,
             producer: [
               topic: topic
             ]
           ),
         true <- Elsa.Producer.ready?(conn) do
      {:ok, %{pid: pid, conn: conn, topic: topic}}
    end
  end

  @impl true
  def handle_cast({:write, messages}, state) do
    Elsa.produce(state.conn, state.topic, List.wrap(messages))
    {:noreply, state}
  end
end
