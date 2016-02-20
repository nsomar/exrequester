use Mix.Config

config :requester,
  request_performer: Requester.Performer.HTTPotion,
  log_requests: false
