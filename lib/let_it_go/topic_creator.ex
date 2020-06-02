defmodule LetItGo.TopicCreator do
  use GenServer, restart: :transient

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, [], {:continue, :create}}
  end

  def handle_continue(:create, state) do
    case create_topic() do
      :ok -> {:stop, :normal, state}
      {:error, reason} -> {:stop, reason, state}
    end
  end

  defp create_topic do
    topic = "let-it-go-topic"
    kafka = Application.get_env(:let_it_go, :kafka, localhost: 9092)

    if Elsa.topic?(kafka, topic), do: :ok, else: Elsa.create_topic(kafka, topic)
  end
end
