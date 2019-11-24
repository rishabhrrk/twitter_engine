defmodule TwitterEngine.Server do
  use GenServer
  # start server's supervisor
  def start_link(_state) do
    # Set initial state to an empty Map
    GenServer.start_link(__MODULE__, %{})
  end

  # Callbacks
  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  # create entry in user ets table
  def handle_call({:create_account, user_id}, _from, state) do
    new_user = %{
      subscribers: [],
      notifications: [],
      tweets: []
    }
    user_map = Map.get(state, :users)
    user_map = Map.put(user_map, user_id, new_user)
    state = Map.put(state, :users, user_map)
    {:reply, :ok, state}
  end

  # fetch a particular user from the server user map
  def handle_call({:fetch_user, user_id}, _from, state) do
    user = Map.get(state, :users)
      |> Map.get(user_id)
    end)
    {:reply, user, state}
  end

  # send back subscriber's list of a user
  def handle_call({:subscriber_list, user_id}, _from, state) do
    user = GenServer.call(TwitterEngine.Server, {:fetch_user, user_id})
    subscriber_list = Map.get(user, :subscribers)
    {:reply, subscriber_list, state}
  end

  # send back notifications of a user
  def handle_call({:get_notifications, user_id}, _from, state) do
    user = GenServer.call(TwitterEngine.Server, {:fetch_user, user_id})
    notifications = Map.get(user, :notifications)
    {:reply, notifications, state}
  end

  # create a new tweet for a user
  def handle_call({:create_tweet, user_id, tweet}, _from, state) do
    hashtags = String.split(tweet, " ")
    |> Enum.filter(fn n -> String.at(n,0)=="#" end)
    tagged_users = String.split(tweet, " ")
    |> Enum.filter(fn n -> String.at(n,0)=="@" end)

    new_tweet = %{
      user_id: user_id
      content: tweet,
      is_archived: false,
      hashtags: hashtags,
      tagged_users: tagged_users
    }
    all_tweets = Map.get(state, :tweets)
    hash_function = :crypto.hash(:md5, tweet) |> Base.encode16()
    all_tweets = Map.put(all_tweets, hash_function, new_tweet)
    state = Map.put(state, :tweets, all_tweets)

    user_map = Map.get(state, :users)
    user = Map.get(user_map, user_id)
    user_tweets = Map.get(user, :tweets)
    user_tweets = [hash_function] ++ user_tweets
    user = Map.put(user, :tweets, user_tweets)
    user_map = Map.put(user_map, user_id, user)
    state = Map.put(state, :users, user_map)
    {:reply, :ok, state}
  end

  # subrscribe to a user
  def handle_call({:subscription_request, user_id, [celebrity]}, _from, state) do
    user_map = Map.get(state, :users)
    celebrity_map = Map.get(user_map, celebrity)
    celebrity_subscriber_list = Map.get(celebrity_map, :subscribers)

    celebrity_subscriber_list = [user_id] ++ celebrity_subscriber_list

    celebrity_map = Map.put(celebrity_map, :subscribers, celebrity_subscriber_list)
    user_map = Map.put(user_map, celebrity, celebrity_map)
    state = Map.put(state, :users, user_map)
    {:reply, :ok, state}
  end
end
