set listen [socket -server ClientConnect 9001]

set project ""
set passwd ""
set contact ""

proc tc {num} {
  return [expr $num+1]
}

proc ClientConnect {sock host proc} {
    chan configure $sock -buffering line -blocking 0
    chan event $sock readable [list ReadLine $sock]
}

proc ReadLine {sock} {
    if {[catch {gets $sock line} len] || [eof $sock]} {
        catch {close $sock}
    } elseif { $len >= 0 } {
        ExecLine $sock $line
	#EchoLine $sock $line
    }
}

proc ExecLine {sock line} {
    switch -- [lindex $line 0] {
        create {
	    if {![string equal $::project ""]} {
               ReplyOtherUsing $sock
	       return
	    }
	    set ::project [lindex $line 1]
	    set ::passwd [lindex $line 2]
	    set ::contact [lindex $line 3]
	    SendMessage $sock $line
	}
	release {
	    set proj [lindex $line 1]
	    set password [lindex $line 2]
	    if {[string equal $::project ""]} {
                SendMessage $sock "No project is running"
	    } elseif {[string equal $::project $proj]} {
		if {[string equal $::passwd $password]} {
                    set ::project ""
		    set ::passwd ""
		    set ::contact ""
		    SendMessage $sock "Project $proj has been release"
		} else {
		    SendMessage $sock "Password error"
		}
	    }  else {
                ReplyOtherUsing $sock
	    }
	}
	execute {
	    if {![ValidPasswd [lindex $line 1] [lindex $line 2]]} { 
		ReplyOtherUsing $sock
		return
	    }
            set cmd [lrange $line 3 [llength $line]-1]
	    SendMessage $sock [eval $cmd]
	}
	default {
	    ReplyOtherUsing $sock
	}
    }
}

proc ValidPasswd {proj password} {
    return [string equal $::project $proj] && [string equal $::passwd $password]
}

proc ReplyOtherUsing {sock} {
    SendMessage $sock "Another project $::project is using. Please contact $::contact"
}

proc EchoLine {sock line} {
    global forever
    switch -nocase -- $line {
	default {
	    SendMessage $sock $line
	}
    }
}

proc SendMessage {sock msg} {
    if {[catch {puts $sock $msg} error]} {
        puts stderr "Error writing to socket: $error"
	catch {close $sock}
    }
    puts $msg
}


vwait forever
catch {close $listen}
