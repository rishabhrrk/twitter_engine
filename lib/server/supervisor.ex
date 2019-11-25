defmodule TwitterEngine.Server.Supervisor do
  @default_node_state %{
    users: %{
      "User": %{
        subscribers: [],
        subscriptions: [],
        notifications: [],
        tweets: [],
        active: false
      }
    }
      ,
    tweets: %{
      "hash": %{
        user_id: "User"
        content: "",
        is_archived: false,
        hashtags: [],
        tagged_users: []
      }
    },
    hashtags: %{
      "hashtag": []
    },
    notifications: %{
      id: %{
        type: retweet|hashtag|mention|followed
        tweet: tweet_id
        owner: owner_id
      }
    }
  }

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init() do
    server = Supervisor.child_spec({TwitterEngine.Server, @default_node_state}, id: i)
    Supervisor.init(server, strategy: :one_for_one)
  end
end
