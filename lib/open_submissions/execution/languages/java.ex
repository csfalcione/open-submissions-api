defmodule OpenSubmissions.Execution.Languages.Java do
  alias OpenSubmissions.Execution.Languages.Language
  @behaviour Language

  @impl Language
  def make_source_file(path, source) do
    filename = "Main.java"
    case File.write("#{path}/#{filename}", source) do
      :ok -> {:ok, filename}
      err -> err
    end
  end

  @impl Language
  def build_source_file(path, filename) do
    IO.puts("building")
    case System.cmd("docker", [
      "run",
      "-v", "#{path}:/app",
      "-w", "/app",
      "-i",
      "java:8-alpine",
      "javac",
      filename
    ], stderr_to_stdout: true) do
      {_msg, 0} -> {:ok, "Main"}
      {err, _} -> {:error, err}
    end
  end

  @impl Language
  def get_command(path, artifact) do
    {:ok, "docker run -e RESULT_FILE=$RESULT_FILE -v #{path}:/app -w /app -i java:8-alpine java #{artifact}"}
  end


end