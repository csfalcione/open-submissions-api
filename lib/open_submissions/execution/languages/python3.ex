defmodule OpenSubmissions.Execution.Languages.Python3 do
  alias OpenSubmissions.Execution.Languages.Language
  @behaviour Language

  @impl Language
  def make_source_file(path, source) do
    filename = "main.py"
    case File.write("#{path}/#{filename}", source) do
      :ok -> {:ok, filename}
      err -> err
    end
  end

  @impl Language
  def build_source_file(_path, filename), do: {:ok, filename}

  @impl Language
  def get_command(path, artifact) do
    {:ok, "docker run -e RESULT_FILE=$RESULT_FILE -v #{path}:/app -w /app -i python:3-alpine python #{artifact}"}
  end


end