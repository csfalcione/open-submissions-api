defmodule OpenSubmissions.Execution.Execution do

	alias OpenSubmissions.Submissions.Submission
	alias OpenSubmissions.Problems.Problem

	def execute_all(%Submission{} = submission, %Problem{} = problem, test_cases) do
		test_cases
		|> Enum.map(fn test_case ->
				execute(submission, problem, test_case)
			end)
	end

	def execute(%Submission{code: code, language: lang} = submission,
							%Problem{} = problem,
							_test_case) do
			{:ok, folder_name} = make_folder(submission)
    	{:ok, source} = fill_template(lang, code, problem)
			{:ok, source_file} = make_source_file(lang, source, folder_name)
			{:ok} = build_source_file(lang, folder_name, source_file)



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
		code
	end

	def make_source_file("java", source, folder_name) do
		filename = "Main.java"
		case IO.write("#{folder_name}/#{filename}", source) do
			:ok -> {:ok, filename}
			err -> err
		end
	end

	def build_source_file("java", folder_name, filename) do
		case System.cmd("docker", [
			"run",
			"-v #{File.cwd!()}/#{folder_name}:/app",
			"-w /app",
			"-i",
			"java:8",
			"javac",
			filename
		]) do
			{msg, 0} -> {:ok, msg}
			{err, _} -> {:err, err}
		end
	end


	def execute_command(command, stdin, file, timeout \\ 5000) do
		port = Port.open({:spawn, command}, [
			:stderr_to_stdout,
			:binary,
			{:env, [
				{'RESULT_FILE', file}
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
				{:os_pid, ospid} = Port.info(port, :os_pid)
				Port.close(port)
				System.cmd("kill", ["#{ospid}"]) # for particularly difficult processes
				:timeout
			_ -> # process stopped
				{:ok, output}
		end
  end
end
