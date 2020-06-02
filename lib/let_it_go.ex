defmodule LetItGo do
  @moduledoc """
  `LetItGo` is a simple application meant to demonstrate [elsa](https://hex.pm/packages/elsa)
  usage and configuration. See the [README](../README.md) for usage information.
  """

  @spec write(String.t() | [String.t()]) :: :ok
  defdelegate write(messages), to: LetItGo.KafkaWriter
end
