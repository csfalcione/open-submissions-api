defmodule OpenSubmissions.Execution.Languages.Language do
  @callback make_source_file(path :: String.t, source :: String.t)
    :: {:ok, term} | {:error, term}

  @callback build_source_file(path :: String.t, filename :: String.t)
    :: {:ok, filename :: String.t} | {:error, term}

  @callback get_command(path :: String.t, artifact :: String.t)
    :: {:ok, command :: String.t}
end