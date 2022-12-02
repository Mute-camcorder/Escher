require 'bundler/setup'
require 'discordrb'
require 'droplet_kit'

DO_TOKEN = ENV.fetch "DIGITALOCEAN_ACCESS_TOKEN"
DISCORD_TOKEN = ENV.fetch "DISCORD_TOKEN"
DISCORD_SERVER_ID = ENV.fetch "DISCORD_SERVER_ID"

def server_on
  cluster = find_cluster
  minecraft_nodepool = get_minecraft_nodepool
  return "Nodepool already exists" if not minecraft_nodepool.nil?
  node_pool = DropletKit::KubernetesNodePool.new(name: 'minecraft', size: 's-2vcpu-4gb', count: 1)
  DO_CLIENT.kubernetes_clusters.create_node_pool(node_pool, id: cluster.id)
end
 
def server_off
  cluster = find_cluster
  minecraft_nodepool = get_minecraft_nodepool
  return "Nodepool does not exist" unless not minecraft_nodepool.nil?

  DO_CLIENT.kubernetes_clusters.delete_node_pool(id: cluster.id, pool_id: minecraft_nodepool["id"])
end

def get_minecraft_nodepool
  cluster = find_cluster
  node_pools = cluster.node_pools.filter {|np| np["name"] == "minecraft" }.first
end

def find_cluster
  DO_CLIENT.kubernetes_clusters.all.first
end

DO_CLIENT = DropletKit::Client.new(access_token: DO_TOKEN)
BOT = Discordrb::Bot.new(token: DISCORD_TOKEN, intents: [:server_messages])

command_names = BOT.get_application_commands(server_id: DISCORD_SERVER_ID).map {|c| c.name}

if not command_names.include? "server_on" then
  puts "Creating 'server_on' command"
  BOT.register_application_command(:server_on, 'Turn Minecraft server on', server_id: DISCORD_SERVER_ID)
end
if not command_names.include? "server_off" then
  puts "Creating 'server_off' command"
  BOT.register_application_command(:server_off, 'Turn Minecraft server off', server_id: DISCORD_SERVER_ID)
end

BOT.application_command(:server_on, server_id: DISCORD_SERVER_ID) do |event|
  event.respond(content: 'Server is spinning up, please be patient.')
  server_on
end

BOT.application_command(:server_off, server_id: DISCORD_SERVER_ID) do |event|
  event.respond(content: 'Server is spinning up, please be patient.')
  server_off
end

BOT.run


