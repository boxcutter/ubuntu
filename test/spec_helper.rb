require 'serverspec'
require 'net/ssh'

set :backend, :ssh

# Set PATH (OEL 5 does not include /sbin by default)
set :path, '/usr/local/sbin:/usr/sbin:/sbin:$PATH'
