defmodule MobupayWeb.Router do
  use MobupayWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authenticated do
    plug(Mobupay.Guardian.Pipeline)
    plug(MobupayWeb.Plugs.AssignGuardianResource)
  end

  scope "/", MobupayWeb do
    get("/", PageController, :index)
  end

  scope "/api/v1", MobupayWeb, as: :v1 do
    pipe_through(:api)

    post("/session/login", SessionController, :login)
    post("/session/refresh", SessionController, :refresh)

    get("/onboard/getting-started", OnboardController, :getting_started)
    post("/onboard/check-msisdn", OnboardController, :check_msisdn)
    post("/onboard/partial-onboard", OnboardController, :partial_onboard)
    post("/onboard/verify-otp", OnboardController, :verify_otp)
    post("/onboard/resend-otp", OnboardController, :resend_otp)
    post("/onboard/set-password", OnboardController, :set_password)

    pipe_through(:authenticated)
    delete("/session/logout", SessionController, :logout)

    get("/user", UserController, :user)
    post("/user/add-email", UserController, :add_email)
    post("/user/verify-password", UserController, :verify_password)

    # transactions
    get("/transaction", TransactionController, :transactions)
    post("/transaction/send/self/initiate", TransactionController, :self_initiate)
    post("/transaction/send/self/verify", TransactionController, :verify_transaction)

    # Transfer
    post("/transfer", TransferController, :index)
    post("/transfer/verify", TransferController, :verify)
    post("/transfer/accept/:ref", TransferController, :accept)
    post("/transfer/reject/:ref", TransferController, :reject)
    post("/transfer/reclaim/:ref", TransferController, :reclaim)

    # withdrawal
    get("/withdraw", WithdrawalController, :index)
    post("/withdraw", WithdrawalController, :initiate)
    post("/withdraw/complete", WithdrawalController, :complete)

    # Business
    # resources "/business", BusinessController

    # contact
    get("/contact/search", ContactController, :search)
    post("contact/import/csv", ContactController, :import)
    resources("/contact", ContactController)

    resources("/bank-account", BankAccountController, only: [:create, :delete])
    resources("/card", CardController, only: [:delete])

    get("/misc/resolve-account-number", MiscController, :resolve_account_number)
    get("/misc/validate-international-msisdn", MiscController, :validate_international_msisdn)
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
      pipe_through([:fetch_session, :protect_from_forgery])

      live_dashboard("/dashboard", metrics: MobupayWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through([:fetch_session, :protect_from_forgery])

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
