defmodule TwitterEngine.Client.User do
  # send registeration request to server
  def send_create_account(pid) do
    GenServer.call(TwitterEngine.Server, {:create_account, pid})
  end

  # send subscription request to server for a user
  def send_subscription_request(pid, [user_pid]) do
    GenServer.call(TwitterEngine.Server, {:subscription_request, pid, [user_pid]})
  end

  # get subscribers list from server for a user
  def get_subscriber_list(pid) do
    subscriber_list = GenServer.call(TwitterEngine.Server, {:subscriber_list, pid})
    subscriber_list
  end

  # send tweets to the server from a user
  def create_tweet(pid, tweet) do
    GenServer.call(TwitterEngine.Server, {:create_tweet, pid, tweet})
  end

  # get notifications for a user
  def get_notifications(pid) do
    GenServer.call(TwitterEngine.Server, {:get_notifications, pid})
  end
end
