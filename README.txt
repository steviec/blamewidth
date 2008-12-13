Hello friends,

This is a simple script to login to your iptables-based router, setup and parse bandwidth consumption from iptables, and report the offenders.  It's not horribly user friendly, but hopefully in the near future tomato will add per-IP bandwidth reporting and this script will become unnecessary.

Basic usage:

require 'blamewidth'

# initialize blamewidth
b = Blamewidth.new('192.168.0.1', 'root', 'password')

# setup monitoring for ip range 192.168.0.100 - 150
array_of_ips = (0..50).to_a.map{|i| "192.168.0.#{100 + i}"}
b.setup(array_of_ips)

# print list of hogs, sorted by biggest consumer first
b.blame

# reset bandwidth stats
b.reset


Stevie Clifton
stevie@slowbicycle.com
