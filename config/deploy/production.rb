# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# Don't declare `role :all`, it's a meta role

# role :app, %w{appuser@107.170.21.85 appuser@107.170.96.96}
# role :web, %w{appuser@107.170.21.85 appuser@107.170.96.96}
# role :db,  %w{appuser@107.170.21.85 appuser@107.170.96.96}

# buyhairillusion.com => 107.170.175.12
# hairillusion.net => 107.170.175.13
# hairillusion.com => 162.243.123.73
# gethairillusion.com => 107.170.23.89

role :app, %w{appuser@162.243.123.73 appuser@107.170.23.89 appuser@107.170.175.12 appuser@107.170.175.13}
role :web, %w{appuser@162.243.123.73 appuser@107.170.23.89 appuser@107.170.175.12 appuser@107.170.175.13}
role :db,  %w{appuser@162.243.123.73}

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
# and/or per server
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options
