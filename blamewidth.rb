require 'net/telnet'
include Net

class Blamewidth
  attr_reader :traffic
  
  USER = "root" #Enter username here
  PASSWORD = "ADMIN$" #Enter password here
  
  def traffic
    return @traffic if @traffic
    # grab all traffic statistics and create an IP => bytes hash
    traffic_in = retrieve_iptables_stats(true)
    traffic_out = retrieve_iptables_stats(false)
  
    # merge into single hash of IP => [in_traffic, out_traffic] mappings
    # and remove empty entries
    @traffic = traffic_in.merge(traffic_out) { |k, v1, v2| v2 = [v1, v2] }
    @traffic.reject!{ |k,v| v == [0,0] }
  end
  
  def blame
    puts "IP ADDRESS\tIN(MB)\tOUT(MB)"
    sort_traffic(true).reverse.each do |ip, in_and_out|
      traffic_in, traffic_out = in_and_out
      puts "#{ip}\t#{traffic_in / 1024 / 1024}\t#{traffic_out / 1024 / 1024}"
    end
  end
  
  def sort_traffic(ingress=true)
    index = ingress ? 0 : 1
    traffic.sort { |a, b| a[1][ index ] <=> b[1][ index ] }
  end
  
  def session
    return @session if @session
    s = Net::Telnet::new( "Host" => '192.168.0.1', "Timeout" => 5, "Prompt" => /#/ )
    s.login(USER, PASSWORD)
    @session = s
  end

  private
  
  def retrieve_iptables_stats(ingress=true)
    direction = ingress ? 'in' : 'out'
    iptables_output = session.cmd( "iptables -L traffic_#{direction} -vnx" )
    parse_iptables_stats( iptables_output, ingress)
  end

  def parse_iptables_stats(dump, ingress=true)
    ip_column = ingress ? 7 : 6
    traffic = {}
    lines = dump.split(/\n/)
    lines.each do |line|
      line = line.split("\s")
  
      # create hash of ips with their corresponding traffic7
      traffic[ line[ip_column] ] = line[1].to_i if line[ip_column] =~ /\d.\d.\d.\d/
    end
    traffic
  end

end

b = Blamewidth.new
b.blame

# blame!
# all_traffic = retrieve_traffic
# out_traffic = all_traffic.sort { |a, b| a[1][0] <=> b[1][0] }


# zero the figures
#iptables -Z traffic_out
#iptables -Z traffic_in