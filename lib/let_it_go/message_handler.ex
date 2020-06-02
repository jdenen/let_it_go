defmodule LetItGo.MessageHandler do
  @moduledoc false

  use Elsa.Consumer.MessageHandler

  def init(args) do
    output_file = Keyword.fetch!(args, :filename)
    output_dir = Keyword.fetch!(args, :output_dir)

    File.mkdir_p!(output_dir)

    {:ok, %{path: Path.join([output_dir, output_file])}}
  end

  def handle_messages(messages, state) do
    binary =
      messages
      |> Enum.map(&Map.get(&1, :value))
      |> Enum.join("\n")

    File.write!(state.path, binary)

    {:ack, state}
  end
end
