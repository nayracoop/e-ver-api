defmodule EVerApiWeb.Router do
  use EVerApiWeb, :router
  #alias Guardian.Permissions


  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug EVerApiWeb.AuthAccessPipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated

  end

  pipeline :api_admin do
    plug Guardian.Permissions, ensure: %{admin: [:read, :write]}
  end

  pipeline :api_user do
    plug Guardian.Permissions, ensure: %{user: [:read]}
  end

  scope "/api", EVerApiWeb do
    pipe_through [:api]

    get "/events/:id", EventController, :show
    post "/login", UserController, :sign_in
    # separate the logic from create (for admins usage)
    #post "sign_up", UserController, :sign_up
  end

  scope "/api", EVerApiWeb do
    pipe_through [:api, :auth, :ensure_auth, :api_admin]

    get "/users", UserController, :index
    get "/users/:id", UserController, :show
    post "/users", UserController, :create
    put "/users/:id", UserController, :update
    delete "/users/:id", UserController, :delete

    get "/events", EventController, :index
    post "/events", EventController, :create
    put "/events/:id", EventController, :update
    delete "/events/:id", EventController, :delete

    post "/events/:event_id/speakers", SpeakerController, :create
    put "/events/:event_id/speakers/:id", SpeakerController, :update
    delete "/events/:event_id/speakers/:id", SpeakerController, :delete

    post "/events/:event_id/talks", TalkController, :create
    put "/events/:event_id/talks/:id", TalkController, :update
    delete "/events/:event_id/talks/:id", TalkController, :delete

    post "/events/:event_id/sponsors", SponsorController, :create
    put "/events/:event_id/sponsors/:id", SponsorController, :update
    delete "/events/:event_id/sponsors/:id", SponsorController, :delete
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
