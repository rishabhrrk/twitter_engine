defmodule TwitterEngine.ClientTest do
  use ExUnit.Case

  test "creates num_user processes" do
    num_users = 1000

    TwitterEngine.Client.start(num_users)
    assert length(TwitterEngine.Client.get_users()) == num_users
  end

  test "every user can send a create account request" do
    TwitterEngine.Client.start(1000)
    users = TwitterEngine.Client.get_users()
    user = Enum.at(users, 0)

    assert TwitterEngine.Client.User.send_create_account(user) == :ok
  end

  test "user retrives her/his subscribers accurately" do
    TwitterEngine.Client.start(5)
    users = TwitterEngine.Client.get_users()
    user1 = Enum.at(users, 0)
    user2 = Enum.at(users, 1)

    assert TwitterEngine.Client.User.get_subscriber_list(user1) == []

    TwitterEngine.Client.User.send_subscription_request(user1, [user2])  # Add user2 to the subscriber list of user1
    assert TwitterEngine.Client.User.get_subscriber_list(user1) == [user2]  # Fetch the subscriber list of user1
  end

  test "subsribers receive notifications" do
    TwitterEngine.Client.start(5)
    users = TwitterEngine.Client.get_users()
    user1 = Enum.at(users, 0)
    user2 = Enum.at(users, 1)

    TwitterEngine.Client.User.create_tweet(user2, "Tweet 1")
    assert TwitterEngine.Client.User.get_notifications(user1) == []

    TwitterEngine.Client.User.send_subscription_request(user1, [user2])
    TwitterEngine.Client.User.create_tweet(user2, "Tweet 2")

    assert TwitterEngine.Client.User.get_notifications(user1) == [
      {
        "type": "tweet_from_subscribee",
        "content": "Tweet 2",
        "owner": user2
      }
    ]
  end
end
