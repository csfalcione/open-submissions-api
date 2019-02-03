defmodule OpenSubmissions.Execution.Execution do

	alias OpenSubmissions.Submissions.Submission
	alias OpenSubmissions.Problems.Problem
	alias OpenSubmissions.TestCases.TestCase

	def execute_all(%Submission{} = submission, %Problem{} = problem, test_cases) do
		test_cases
		|> Enum.map(fn %TestCase{output: expected} = test_case ->
				with {:ok, output, stdio} <- execute(submission, problem, test_case) do
					res = {:ok, output, stdio, expected}
					IO.inspect(res)
					res
				else
					err ->
						IO.inspect(err)
						err
				end
			end)
		|> Enum.into([])
	end

	def execute(%Submission{code: code, language: lang} = submission,
							%Problem{} = problem,
							%TestCase{id: case_id, input: case_input}) do
			{:ok, folder_name} = make_folder(submission)
    	{:ok, source} = fill_template(lang, code, problem)
			{:ok, source_file} = make_source_file(lang, source, folder_name)
			IO.puts(source_file)
			with {:ok, _msg, artifact} <-  build_source_file(lang, folder_name, source_file) do
				output_file = "result_#{case_id}.txt"
				stdout = execute_command(
					get_command(lang, folder_name, artifact),
					"#{case_input}\n",
					output_file,
					5000
				)
				case File.read("#{folder_name}/#{output_file}") do
					{:ok, result} -> {:ok, result, stdout}
				  {:error, _} -> {:error, stdout}

				end
			else {:err, err} ->
				{:err, "Compilation error: #{err}"}
			end

	end

	def make_folder(%Submission{id: id}) do
		name = "sub_#{id}"
		with :ok <- File.mkdir_p(name) do
			{:ok, name}
		else _ ->
			{:err}
		end
	end

	def fill_template("java", code, %Problem{} = _problem) do
		{:ok, code}
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
			{err, _} -> {:err, err}
		end
	end


	def get_command("java", folder_name, artifact) do
		"docker run -e RESULT_FILE=$RESULT_FILE -v $PWD/#{folder_name}:/app -w /app -i java:8 java #{artifact}"
	end

	def execute_command(command, stdin, file, timeout \\ 5000) do
		IO.inspect({command, stdin, file})
		port = Port.open({:spawn, command}, [
			:stderr_to_stdout,
			:binary,
			{:env, [
				{'RESULT_FILE', String.to_charlist(file)}
			]}
		])

		{:ok, _} = :timer.send_after(timeout, {:kill_this_process, port})

		Port.command(port, stdin)
		Port.monitor(port)
		receive_output()

	end

	def receive_output(output \\ "") do
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
					:timeout
				else _ -> :timeout
				end
			_ -> # process stopped
				{:ok, output}
		end
  end
end
