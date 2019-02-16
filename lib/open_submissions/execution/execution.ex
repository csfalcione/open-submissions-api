defmodule OpenSubmissions.Execution.Execution do

  alias OpenSubmissions.Submissions.Submission
  alias OpenSubmissions.Problems.Problem
  alias OpenSubmissions.TestCases.TestCase
  alias OpenSubmissions.Execution.Languages

  def execute_all(%Submission{language: lang_name} = submission, %Problem{} = problem, test_cases) do
    with {:ok, language} <- get_language_implementation(lang_name),
      {:ok, path} <- make_folder(submission),
      {:ok, source} <- fill_template(submission, problem),
      {:ok, source_file} <- language.make_source_file(path, source),
      {:ok, artifact_name} <- language.build_source_file(path, source_file),
      {:ok, command} <- language.get_command(path, artifact_name) do
        
        test_cases
        |> Task.async_stream( fn %TestCase{} = test_case ->
            case execute(test_case, command, path) do
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
          {:error, %{stdout: stdout}}
      end
    end

  end

  def get_language_implementation(lang) do
    case lang do
      "java" -> {:ok, Languages.Java}
      "python3" -> {:ok, Languages.Python3}
      _ -> {:error, "Language not supported"}
    end
  end


  def make_folder(%Submission{id: id}) do
    path = "#{File.cwd!()}/sub_#{id}"
    with :ok <- File.mkdir_p(path) do
      {:ok, path}
    end
  end

  def fill_template(%Submission{code: snippet}, %Problem{} = _problem) do
    {:ok, snippet}
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
