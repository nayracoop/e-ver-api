defmodule EVerApiWeb.Router do
  use EVerApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug EVerApi.AuthAccessPipeline
  end

  scope "/api", EVerApiWeb do
    get "/events/:id", EventController, :show
    post "/login", UserController, :sign_in
    # separate the logic from create (for admins usage)
    #post "sign_up", UserController, :sign_up
  end

  scope "/api", EVerApiWeb do
    pipe_through [:api, :jwt_authenticated]

    get "/users", UserController, :index
    get "/users/:id", UserController, :show
    post "/users", UserController, :create
    put "/users/:id", UserController, :update
    delete "/users/:id", UserController, :delete

    get "/events", EventController, :index
    post "/events", EventController, :create

    #get "/talks", TalkController, :index
    #get "/talks/:id", TalkController, :show
    #post "/talks", TalkController, :create
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
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: EVerApiWeb.Telemetry
    end
  end
end
