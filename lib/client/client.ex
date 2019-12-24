defmodule TwitterEngine.Client do

  @server {:global, :server}

  def run_simulation(num_users, num_messages) do
    :global.register_name :client, self()
    TwitterEngine.Client.Supervisor.create_users(num_users)

    users =
      Supervisor.which_children(TwitterEngine.Client.Supervisor)
      |> Enum.map(fn {_, pid, :worker, _} -> pid end)

    # Starting simulation
    start_time = Time.utc_now()

    Enum.each(users, fn user ->
      {:ok, user_id} = TwitterEngine.Client.User.create_account(user)
      send user, {:set_username, user_id}
      send user, {:send_random_request, num_messages}
    end)

    wait_till_all_requests_are_sent(num_users, start_time)
  end

  def wait_till_all_requests_are_sent(n, start_time) do
    if n > 0 do
      receive do
        :done ->
          wait_till_all_requests_are_sent(n - 1, start_time)
        {:notification, notification, pid} ->
          IO.puts "User #{inspect pid} received: #{notification}"
          wait_till_all_requests_are_sent(n, start_time)
      end
    else
      end_time = Time.utc_now()
      time_taken = Time.diff(end_time, start_time, :millisecond)

      IO.gets "\nAll users have finished sending num_messages messages. Press [Enter] to terminate and print DB stats"
      stats = GenServer.call @server, :get_db_stats

      IO.puts "\nDB stats"
      IO.puts "========"
      Enum.each stats, fn {k, v} ->
        IO.puts "#{k}:\t#{v}"
      end

      IO.puts "\nThe simulation took #{time_taken} ms"
    end
  end
end
