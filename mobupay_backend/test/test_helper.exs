{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(Mobupay.Repo, :manual)

Mox.defmock(Mobupay.Clients.TwilioServiceMock, for: Mobupay.Clients.TwilioServiceClient)
Mox.defmock(Mobupay.Clients.PaystackServiceMock, for: Mobupay.Clients.PaystackServiceClient)

Application.put_env(:mobupay, :twilio_service, Mobupay.Clients.TwilioServiceMock)
Application.put_env(:mobupay, :paystack_service, Mobupay.Clients.PaystackServiceMock)
