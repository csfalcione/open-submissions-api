defmodule OpenSubmissions.Execution.Languages.C do
  alias OpenSubmissions.Execution.Languages.Language
  @behaviour Language

  @impl Language
  def make_source_file(path, source) do
    filename = "main.c"
    case File.write("#{path}/#{filename}", source) do
      :ok -> {:ok, filename}
      err -> err
    end
  end

  @impl Language
  def build_source_file(path, filename) do
    IO.puts("building")
    artifact = "main.out"
    case System.cmd("docker", [
      "run",
      "-v", "#{path}:/app",
      "-w", "/app",
      "-i",
      "frolvlad/alpine-gcc",
      "gcc",
      "-o", artifact,
      filename
    ], stderr_to_stdout: true) do
      {_msg, 0} -> {:ok, artifact}
      {err, _} -> {:error, err}
    end
  end

  @impl Language
  def get_command(path, artifact) do
    {:ok, "docker run -e RESULT_FILE=$RESULT_FILE -v #{path}:/app -w /app -i alpine ./#{artifact}"}
  end


end