defmodule AuctionWeb.Router do
  use AuctionWeb, :router

  """
  Every request that goes through the / top-level route is piped through this browser
  pipeline. We need to fetch the session before we try to access it in our plug (with
  Plug.Conn.get_session/2), so perhaps the best place to put the authenticator is at
  the end of the browser pipeline.
  """

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AuctionWeb.Authenticator
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AuctionWeb do
    pipe_through :browser

    get "/closed", ItemController, :closed, as: :closed

    resources "/items", ItemController, only: [:index, :new, :create, :show, :edit, :update] do
      resources "/bids", BidController, only: [:create]
    end

    resources "/users", UserController, only: [:show, :new, :create]

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", AuctionWeb.Api do
    pipe_through :api

    """
    already have an AuctionWeb.ItemController that handles HTML requests, but
    now you’ll introduce a AuctionWeb.Api.ItemController to handle JSON requests.
    The namespacing keeps them separate and communicates their purpose.
    """

    resources "/items", ItemController, only: [:index, :show]
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: AuctionWeb.Telemetry
    end
  end
end
