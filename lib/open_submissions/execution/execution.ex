defmodule OpenSubmissions.Execution.Execution do

  alias OpenSubmissions.Submissions.Submission
  alias OpenSubmissions.Problems.Problem
  alias OpenSubmissions.TestCases.TestCase

  def execute_all(%Submission{language: lang} = submission, %Problem{} = problem, test_cases) do
    with {:ok, folder_name} <- make_folder(submission),
      {:ok, source} <- fill_template(submission, problem),
      {:ok, source_file} <- make_source_file(lang, source, folder_name),
      {:ok, _, artifact_name} <- build_source_file(lang, folder_name, source_file),
      {:ok, command} <- get_command(lang, folder_name, artifact_name) do
        
        test_cases
        |> Task.async_stream( fn %TestCase{} = test_case ->
            case execute(test_case, command, folder_name) do
              {:ok, results} -> results
              {_time, {:error, error}} -> %{error: error, test_case: test_case}
              {:error, error} -> %{error: error, test_case: test_case}
            end
          end, timeout: 20_000, on_timeout: :kill_task, ordered: true)
        |> Stream.zip(test_cases)
        |> Stream.map(fn {result, test_case} -> 
            case result do
              {:ok, res} -> res
              {:exit, :timeout} -> %{error: "timeout", test_case: test_case}
            end
          end)
        |> Enum.to_list
    else
      {:error, error} -> %{error: error}
    end

  end

  def execute( %TestCase{} = test_case, command, folder_name, timeout \\ 5000 ) do

    with stdin <- get_stdin(test_case),
      output_filename <- make_output_filename(test_case),
      {time_taken, {:ok, stdout}} <- time( fn -> execute_command(command, stdin, output_filename, timeout) end ) do
      case read_problem_result(folder_name, output_filename) do
        {:ok, problem_result} -> 
          {:ok, %{ stdout: stdout, output: problem_result, time: time_taken, test_case: test_case } }
        {:error, :submission_error} -> 
          {:error, %{stdout: stdout, test_case: test_case}}
      end
    end

  end


  def make_folder(%Submission{id: id}) do
    name = "sub_#{id}"
    with :ok <- File.mkdir_p(name) do
      {:ok, name}
    end
  end

  def fill_template(%Submission{code: snippet}, %Problem{} = _problem) do
    {:ok, snippet}
  end

  def make_source_file("java", source, folder_name) do
    filename = "Main.java"
    case File.write("#{folder_name}/#{filename}", source) do
      :ok -> {:ok, filename}
      err -> err
    end
  end

  def build_source_file("java", folder_name, filename) do
    IO.puts("building")
    case System.cmd("docker", [
      "run",
      "-v", "#{File.cwd!()}/#{folder_name}:/app",
      "-w", "/app",
      "-i",
      "java:8-alpine",
      "javac",
      filename
    ], stderr_to_stdout: true) do
      {msg, 0} -> {:ok, msg, "Main"}
      {err, _} -> {:error, err}
    end
  end


  def get_command("java", folder_name, artifact) do
    {:ok, "docker run -e RESULT_FILE=$RESULT_FILE -v $PWD/#{folder_name}:/app -w /app -i java:8-alpine java #{artifact}"}
  end

  def get_stdin(%TestCase{input: input}) do
    "#{input}\n"
  end

  def make_output_filename(%TestCase{id: id}) do
    "result_#{id}.txt"
  end


  def execute_command(command, stdin, output_filename, timeout \\ 5000) do
    IO.inspect({command, stdin, output_filename})
    port = Port.open({:spawn, command}, [
      :stderr_to_stdout,
      :binary,
      {:env, [
        {'RESULT_FILE', String.to_charlist(output_filename)}
      ]}
    ])

    {:ok, _} = :timer.send_after(timeout, {:kill_this_process, port})

    Port.command(port, stdin)
    Port.monitor(port)
    receive_output()

  end


  defp receive_output(output \\ "") do
    receive do
      # more data received from the port
      {port, {:data, data}} ->
        new_output = output <> data
        case Port.info(port) do
          nil -> {:ok, new_output} # port closed, return collected stdout
          _ -> receive_output(new_output) # probably more output to collect
        end

      # we timed out
      {:kill_this_process, port} ->
        with {:os_pid, ospid} <- Port.info(port) do
          Port.close(port)
          System.cmd("kill", ["#{ospid}"]) # for particularly difficult processes
        end
        {:error, "timeout"}

      # anything else means we already have all the output
      _ -> {:ok, output}
    end
  end


  def read_problem_result(folder, filename) do
    case File.read("#{folder}/#{filename}") do
      {:error, :enoent} -> {:error, :submission_error}
      other -> other
    end
  end

  defp time(action) do
    time_before = System.monotonic_time(:millisecond)
    result = action.()
    time_after = System.monotonic_time(:millisecond)
    {time_after - time_before, result}
  end

end
