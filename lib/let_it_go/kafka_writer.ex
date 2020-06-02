defmodule LetItGo.KafkaWriter do
  use GenServer

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    with kafka <- Application.get_env(:let_it_go, :kafka, localhost: 9092),
         {:ok, pid} <-
           Elsa.Supervisor.start_link(
             connection: :let_it_go_writer,
             endpoints: kafka,
             producer: [
               topic: "let-it-go-topic"
             ]
           ),
         true <- Elsa.Producer.ready?(:let_it_go_writer) do
      {:ok, pid}
    end
  end
end
