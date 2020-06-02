defmodule LetItGo do
  defdelegate write(messages), to: LetItGo.KafkaWriter
end
