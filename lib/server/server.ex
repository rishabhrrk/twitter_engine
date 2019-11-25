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

  # return the state to caller
  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  # set the state sent by the caller
  def handle_call({:set_state, new_state}, _from, state) do
    {:reply, :ok, new_state}
  end

  # check if the user is active
  def handle_call({:user_alive, user_id}, _from, state) do
    user = GenServer.call(TwitterEngine.Server, {:fetch_user, user_id})
    active_flag = Map.get(user, :active)
    {:reply, active_flag, state}
  end

  # create a user
  def handle_call({:create_account, user_id}, _from, state) do
    TwitterEngine.Server.Models.User.create(user_id)
    {:reply, :ok, state}
  end

  # delete a user
  def handle_call({:delete_account, user_id}, _from, state) do
    # make account as inactive
    TwitterEngine.Server.Models.User.delete(user_id)

    # archive tweets
    tweet_list = TwitterEngine.Server.Models.User.query(user_id, "tweets")

    Enum.each(tweet_list, fn tweet_id ->
      TwitterEngine.Server.Models.Tweet.delete(tweet_id)
    end)

    # remove user from subscriber's list of all celebrities
    celebrity_list = TwitterEngine.Server.Models.User.query(user_id, "subscriptions")

    Enum.each(celebrity_list, fn celebrity_id ->
      TwitterEngine.Server.Models.Tweet.delete_fromList(celebrity_id, "subscribers", user_id)
    end)

    {:reply, :ok, state}
  end

  # send back subscriber's list of a user
  def handle_call({:subscriber_list, user_id}, _from, state) do
    subscriber_list = TwitterEngine.Server.Models.User.query(user_id, "subscribers")
    {:reply, subscriber_list, state}
  end

  # send back notifications of a user
  def handle_call({:get_notifications, user_id}, _from, state) do
    notifications = TwitterEngine.Server.Models.User.query(user_id, "notifications"))
      |> Enum.map(fn id -> [TwitterEngine.Server.Models.Notification.get(id)] end)

    {:reply, notifications, state}
  end

  # create a new tweet for a user
  def handle_call({:create_tweet, user_id, tweet}, _from, state) do
    # create new tweet
    tweet_id = TwitterEngine.Server.Models.Tweet.create(user_id, tweet)

    # add tweet_id to user's tweet list
    TwitterEngine.Server.Models.User.add_toList(user_id, "tweets", tweet_id)

    # send tweet to all its subscribers
    notification_id =
      TwitterEngine.Server.Models.Notification.create("followed", tweet_id, user_id)

    subscriber_list = TwitterEngine.Server.Models.User.query(user_id, "subscribers")

    Enum.each(subscriber_list, fn subscriber ->
      TwitterEngine.Server.Models.User.add_toList(subscriber, "notifications", notification_id)
    end)

    # send tweet to all tagged persons
    notification_id =
      TwitterEngine.Server.Models.Notification.create("mention", tweet_id, user_id)

    tagged_users = TwitterEngine.Server.Models.Tweet.query(tweet_id, "tagged_users")

    Enum.each(tagged_users, fn tag ->
      TwitterEngine.Server.Models.User.add_toList(tag, "notifications", notification_id)
    end)

    # send tweet to all people following hashtags
    notification_id =
      TwitterEngine.Server.Models.Notification.create("hashtag", tweet_id, user_id)

    hashtags = TwitterEngine.Server.Models.Tweet.query(tweet_id, "hashtags")

    Enum.each(hashtags, fn tag ->
      TwitterEngine.Server.Models.Hashtags.get(tag)
      |> Enum.each(fn follower ->
        TwitterEngine.Server.Models.User.add_toList(follower, "notifications", notification_id)
      end)
    end)

    {:reply, :ok, state}
  end

  # subrscribe to a user
  def handle_call({:subscription_request, user_id, celebrity}, _from, state) do
    # add user to subscriber list of celebrity
    TwitterEngine.Server.Models.User.add_toList(celebrity, "subscribers", user_id)

    # add celebrity to subscription list of user
    TwitterEngine.Server.Models.User.add_toList(user_id, "subscription", celebrity)
    {:reply, :ok, state}
  end

  # subrscribe to a hashtag
  def handle_call({:subscribe_hashtag, user_id, hashtag}, _from, state) do
    # add user to hashtag's user list
    TwitterEngine.Server.Models.Hashtags.add_toList(hashtag, user_id)
    {:reply, :ok, state}
  end
end
