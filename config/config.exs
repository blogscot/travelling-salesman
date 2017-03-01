# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :tsp, nodes: [
   :"node1@127.0.0.1",
   :"node2@127.0.0.1",
   # :"node1@10.1.5.30",
   # :"node2@10.1.5.31",
   # :"node1@192.168.56.101",
   # :"node2@192.168.56.102",
]

# tell logger to load a LoggerFileBackend processes
config :logger,
  backends: [{LoggerFileBackend, :info}]

config :logger, :info,
  path: "logs/info.log",
  level: :info
