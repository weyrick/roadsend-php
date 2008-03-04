<?php

function necho ($line_number, $string) {
  echo "$line_number: $string\n";
  return $string;
}

// checkdnsrr
if (PHP_OS != 'WINNT') {
necho(10,  checkdnsrr('roadsend.com'));
necho(20,  checkdnsrr('roadsend.com','A'));
necho(30,  checkdnsrr('blah.roadsend.com','A'));
necho(40,  checkdnsrr('roadsend.com','MX'));
necho(50,  checkdnsrr('roadsend.com','SOA'));
necho(60,  checkdnsrr('roadsend.com','PTR'));
necho(70,  checkdnsrr('smtp.roadsend.com','CNAME'));
necho(80,  checkdnsrr('joplin.roadsend.com','CNAME'));
necho(90,  checkdnsrr('roadsend.com','ANY'));
 necho(100, checkdnsrr('-no-way-inthe-w0rld.com','MX'));
}

// gethostbyname
necho(110, gethostbyname('www.roadsend.com'));
necho(120, gethostbyname('tenkan.org'));
necho(130, gethostbyname('localhost'));

// gethostbyaddr
necho(140, gethostbyaddr('127.0.0.1'));
necho(150, gethostbyaddr('216.244.107.14'));
necho(160, gethostbyaddr('216.239.59.99'));

// dns_check_record --- apparently they do not actually implement this, though it says they do in the manual
//necho(180, dns_check_record('kobain.roadsend.com', 'a'));
//necho(190, dns_check_record('hendrix.roadsend.com', 'any'));

// getprotobyname
necho(200, getprotobyname('ip'));
necho(210, getprotobyname('tcp'));
necho(220, getprotobyname('icmp'));
necho(230, getprotobyname('udp'));

// getprotobynumber
necho(240, getprotobynumber(0));
necho(250, getprotobynumber(1));
necho(260, getprotobynumber(17));
necho(270, getprotobynumber(6));

// getservbyname
necho(280, getservbyname('smtp','tcp'));
necho(290, getservbyname('daytime','udp'));
necho(300, getservbyname('echo','tcp'));
necho(310, getservbyname('ssh','tcp'));
necho(320, getservbyname('foobar','udp'));

// getservbyport
necho(330, getservbyport(19,'udp'));
necho(340, getservbyport(23,'tcp'));
necho(350, getservbyport(7,'udp'));
necho(360, getservbyport(119,'tcp'));
necho(370, getservbyport(123,'udp'));

/*
if (PHP_OS != 'WINNT') {
    
// openlog, syslog, closelog
$openlog_options = array(LOG_CONS, LOG_NDELAY, LOG_ODELAY, LOG_PERROR, LOG_PID);
$openlog_facilities = array(LOG_AUTH, LOG_AUTHPRIV, LOG_CRON, LOG_DAEMON, LOG_KERN,    
                            LOG_LPR, LOG_MAIL, LOG_NEWS, LOG_SYSLOG, LOG_USER,
                            LOG_UUCP, LOG_LOCAL0, LOG_LOCAL1, LOG_LOCAL2, LOG_LOCAL3,
                            LOG_LOCAL4, LOG_LOCAL5, LOG_LOCAL6, LOG_LOCAL7);
$syslog_priorities = array(LOG_EMERG, LOG_ALERT, LOG_CRIT, LOG_ERR, LOG_WARNING, 
                           LOG_NOTICE, LOG_INFO, LOG_DEBUG);
$tmpfile = '/tmp/pcc-syslog-test-output';
$id = "PCC_".rand()."_TEST";
//necho(395, "id is $id");
foreach ($openlog_options as $option) {
  foreach ($openlog_facilities as $facility) {
    openlog("PCC_TEST", $option, $facility);
    foreach ($syslog_priorities as $priority) {
      necho(380 + ($count / 1000), "option=$option, facility=$facility, priority=$priority, count=$count");
      syslog($priority, "$id: option=$option, facility=$facility, priority=$priority");
    }
    closelog();
  }
}
*/

necho(400, "log output: ");
if (posix_geteuid() == 0) {
  system("tail -5000 `find /var/log -type f` | grep -a $id | sed s/..:..:..//g | sed 's/PCC_TEST\[.*\]/PCC_TEST/' | sed 's/$id/PCC_TEST/' | sort");
}

// define_syslog_variables
necho(410, define_syslog_variables());

//} // winnt 

// gethostbynamel
necho(520, gethostbynamel('www.roadsend.com'));
necho(530, gethostbynamel('tenkan.org'));
necho(540, gethostbynamel('localhost'));

// getmxrr
if (PHP_OS != 'WINNT') {
$mxhosts = array();
$weights = array();
necho(550, getmxrr('roadsend.com', &$mxhosts, &$weights));
sort($mxhosts);
sort($weights);
necho(560, "mxhosts: ");
print_r($mxhosts);
necho(570, "weights: ");
print_r($weights);
necho(580, getmxrr('google.com', &$mxhosts, &$weights));
sort($mxhosts);
sort($weights);
necho(590, "mxhosts: ");
print_r($mxhosts);
necho(600, "weights: ");
print_r($weights);
}


// mail
//mail("sitemanager@roadsend.com", "Test Subject", "Line 1\nLine 2\nLine 3");
//mail("sitemanager@roadsend.com", "Test Subject", "Line 1\nLine 2\nLine 3", "From: raven@roadsend.com\r\nReply-To: pym@roadend.com");

?>