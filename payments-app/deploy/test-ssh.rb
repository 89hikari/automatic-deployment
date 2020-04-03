require 'net/ssh'

Net::SSH.start('192.168.1.114', 'user', password: 'user') do |ssh|
    output = ssh.exec!("hostname")
    puts output
end