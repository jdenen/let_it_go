defmodule LetItGo.KafkaWriter do
  use GenServer

  def write(messages) do
    GenServer.cast(__MODULE__, {:write, messages})
  end

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    with conn <- :let_it_go_writer,
         topic <- "let-it-go-topic",
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

  def handle_cast({:write, messages}, state) do
    Elsa.produce(state.conn, state.topic, List.wrap(messages))
    {:noreply, state}
  end
end
