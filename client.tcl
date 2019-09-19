set sockid [socket localhost 9001]

puts $sockid "create zjt zjt zjt"
flush $sockid
set msg [gets $sockid]
puts $msg

puts $sockid "execute hello"
flush $sockid
set msg [gets $sockid]
puts $msg

puts $sockid "execute zjt zjt tc 123"
flush $sockid
set msg [gets $sockid]
puts $msg

close $sockid
