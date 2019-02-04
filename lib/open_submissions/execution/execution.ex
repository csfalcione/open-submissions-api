defmodule OpenSubmissions.Execution.Execution do

	alias OpenSubmissions.Submissions.Submission
	alias OpenSubmissions.Problems.Problem
	alias OpenSubmissions.TestCases.TestCase

	def execute_all(%Submission{} = submission, %Problem{} = problem, test_cases) do
		test_cases
		|> Enum.map(fn %TestCase{output: expected} = test_case ->
				case execute(submission, problem, test_case) do
					{:ok, results} -> results
					{:error, error} -> %{error: error, test_case: test_case}
				end
			end)
		|> Enum.into([])
	end

	def execute(%Submission{language: lang} = submission,
							%Problem{} = problem,
							%TestCase{} = test_case) do

		with(
			{:ok, folder_name} <- make_folder(submission),
			{:ok, source} <- fill_template(submission, problem),
			{:ok, source_file} <- make_source_file(lang, source, folder_name),
			{:ok, _, artifact} <- build_source_file(lang, folder_name, source_file),
			{:ok, command} <- get_command(lang, folder_name, artifact),
			stdin <- get_stdin(test_case),
			output_filename <- make_output_filename(test_case),
			{:ok, stdout} <- execute_command(command, stdin, output_filename, 5000),
			{:ok, problem_result} <- read_problem_result(folder_name, output_filename),
			do: {:ok, %{ stdout: stdout, output: problem_result, test_case: test_case } }
		)

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
			"java:8",
			"javac",
			filename
		]) do
			{msg, 0} -> {:ok, msg, "Main"}
			{err, _} -> {:error, err}
		end
	end


	def get_command("java", folder_name, artifact) do
		{:ok, "docker run -e RESULT_FILE=$RESULT_FILE -v $PWD/#{folder_name}:/app -w /app -i java:8 java #{artifact}"}
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
			{port, {:data, data}} -> # receive more data
				new_output = output <> data
				with nil <- Port.info(port) do # Port closed
					{:ok, new_output}
				else
					_ -> # Port still open
						receive_output(new_output)
				end
			{:kill_this_process, port} -> # timed out
				with {:os_pid, ospid} <- Port.info(port, :os_pid) do
					Port.close(port)
					System.cmd("kill", ["#{ospid}"]) # for particularly difficult processes
					{:error, "timeout"}
				else _ -> {:error, "timeout"}
				end
			_ -> # process stopped
				{:ok, output}
		end
	end


	def read_problem_result(folder, filename) do
		File.read("#{folder}/#{filename}")
	end

end
