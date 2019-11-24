defmodule TwitterEngine.Client do
  def start(num_nodes) do
    TwitterEngine.Client.Supervisor.create_nodes(num_nodes)
  end
  def get_users() do
    pids =
      Supersor.which_children(TwitterEngine.Client.Supervisor)
      |> Enum.map(fn {_, pid, :worker, _} -> pid end)

    pids
  end
  def send_create_account_requests() do
    pids = get_users()
    |> Enum.each(fn user -> TwitterEngine.Client.User.send_create_account(user))
  end
end
