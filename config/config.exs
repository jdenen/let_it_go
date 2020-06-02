import Config

config :let_it_go,
  kafka: [localhost: 9092],
  divo: [DivoKafka],
  divo_wait: [dwell: 700, max_tries: 50]
