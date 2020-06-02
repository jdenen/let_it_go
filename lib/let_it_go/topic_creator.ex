defmodule LetItGo.TopicCreator do
  @moduledoc """
  This is a transient process wrapping topic creation with `Elsa`.

  ## Why a process?

  We prefer a process like this to a function because it affords us some wiggle room. If topic
  creation was implemented as a private function in `LetItGo.Application`, then `LetItGo` would
  blow up before its supervisor was started if Kafka was unreachable. As part of a process, this
  operation can be supervised and may recover if Kafka becomes reachable again.

  Now usually, this would be a part of a `handle_continue/2` callback in another process that
  requires the topic in question (like `LetItBe.KafkaWriter`). But I wanted to simplify the code
  and separate concerns for this example.

  ## Idempotence

  You should always wrap `Elsa.create_topic/2` calls with `Elsa.topic?/2` to ensure idempotent
  operations. If a topic exists, `:brod` (and thus `Elsa`) will blow up when you try to create it.

  You could technically `rescue` the exception raised by re-creating an existing topic, but that
  puts more resource strain on your Kafka cluster than a simple metadata check.
  """
  use GenServer, restart: :transient

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, [], {:continue, :create}}
  end

  @impl true
  def handle_continue(:create, state) do
    case create_topic() do
      :ok -> {:stop, :normal, state}
      {:error, reason} -> {:stop, reason, state}
    end
  end

  defp create_topic do
    topic = Application.get_env(:let_it_go, :topic, "let-it-go-topic")
    kafka = Application.get_env(:let_it_go, :kafka, localhost: 9092)

    if Elsa.topic?(kafka, topic), do: :ok, else: Elsa.create_topic(kafka, topic)
  end
end
