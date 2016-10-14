

## Introduction to DBGp Proxy

Link: https://derickrethans.nl/debugging-with-multiple-users.html

## Multi-user Debugging with Xdebug, DBGp and PHPStorm

* http://tech-tamer.com/multi-user-debugging-with-xdebug-dbgp-and-phpstorm/

> Just put “9001” and it will only listen for connections from localhost; not helpful if you’re trying to connect from a 
different computer.  Specify a particular address (either by IP or hostname), and it will only listen for connections
from that address; not helpful when the developers on the local network have different hostnames/IP addresses.
Specify a subnet (e.g. “192.168.1.0”) and it still only listens to localhost.  Specify 0.0.0.0 and it will accept 
connections on port 9001 from anyone.  Do be sure you are running a good, well-configured firewall, ok?

Example:

> The last line starts the proxy server, and tells it how to listen for developers (the -i parameter) and how to talk to
Xdebug (the -d parameter). 

    #!/bin/sh
    cd /home/[USER]/bin/Komodo-PythonRemoteDebugging
    export PYTHONPATH=./pythonlib:./python3lib:$PYTHONPATH
    python pydbgpproxy -i 0.0.0.0:9001 -d 9000

RALLEN: I think the example above has DBGp on the same box as the web server, therefore -d does not specify any
parameters.

RALLEN: We might want to switch the "debugger" `-d` to talk to the XDEBUG extension on the PHP-FPM container, otherwise,
DBGp might be accepting connections from the IDEs successfully, but then not finding XDebug!!


## Komodo DBGp extension

Download: http://downloads.activestate.com/Komodo/releases/

PIP version:
  * https://github.com/agroszer/komodo-python-dbgp
  * https://pypi.python.org/pypi/komodo-python-dbgp


## Komodo debugger proxy Docker container

Link: https://github.com/christian-blades-cb/docker-dbgp-proxy

Example of proxying  xdebug sessions through a separate container.


## Multi-user debugging in PhpStorm with Xdebug and DBGp proxy

Reference: https://confluence.jetbrains.com/display/PhpStorm/Multi-user+debugging+in+PhpStorm+with+Xdebug+and+DBGp+proxy

    [xdebug]
    zend_extension=xdebug_module_goes_here
    xdebug.remote_enable=1
    xdebug.remote_host=hostname_or_ip_of_the_dbgp_proxy_goes_here
    xdebug.remote_port=9000


In order to be able to proxy the various debugging sessions, we'll need a DBGp proxy on a server that can be reached by 
the web server itself as well as all developer machines. We can install it on the web server, or on a machine in the 
same network (or with an SSH tunnel to the web server).






## Komodo DBGp documentation
   
Link: https://community.activestate.com/faq/komodo-ide-debugger-proxy-pydbgpproxy

* The proxy is started first, and listens on two separate ports.
* Komodo connects to the proxy on one port to tell it the specific proxy key Komodo is using, as well as the IP address
  and port number Komodo is listening on.
* The application being debugged connects to the proxy on the other proxy port when it starts a debugging session,
  sending the required ide key.
* The proxy service checks the idekey (proxy key) given by the application being debugged and tries to match it to the
  connected Komodo session(s). If one matches, then the proxy tries to initiate a connection to this Komodo application 
  and if successful the debug session is passed on to Komodo. When no match is found, the debug session is ignored.

Start the proxy by navigating to the containing folder of pydbgpproxy.exe, note that the DBGP proxy service can be 
running anywhere (a linux machine, windows, mac...), as long as both the application/server to be debugged and Komodo 
IDE have TCP/IP access to connect to this proxy instance and vice-versa. I'll call the machine "mymachine" in the 
examples below.


    # Here is the command to start the proxy "dbgpproxy -i IDE-PORT -d DEBUG-PORT":
    pydbgpproxy -i 9001 -d 9000
    
`-i IDE_PORT`: where the IDE will connect to.
`-d DEBUG_PORT`: where the application will connect to.

XDebug by default uses port 9000, so it is a good idea to leave it a port 9000.


### What alternatives do I have when the two machines cannot see (connect to) each other?

If you have machine A and machine B that cannot connect to each other, you may be able to use ssh port forwarding to 
pass the connection along between the two (often useful in the case of a vpn/private network, or where you have only 
access to an intermediate machine). The actual technique used is what is called a reverse SSH port forwarding, 
see http://toic.org/2009/01/18/reverse-ssh-port-forwarding/.

Run the following code on the client machine (Note: the client machine is where the code is actually running):

    ssh -R 9000:localhost:9000 komodo.machine.com

if using an intermediate host, replace the localhost with the client address like this:

    ssh -R 9000:client.machine.com:9000 komodo.machine.com

Once setup, you should be able to set Komodo to listen for connections locally on port 9000, and set the client to 
connect to the debugger on it's locally on port 9000 and the ssh tunnel will pass the connection between the two 
(three for intermediate) machines.


## Proxy parameters

    docker-compose exec dbgp-proxy bash
    root@d0e314ede4f5:/# pydbgpproxy --help

    pydbgpproxy -- a proxy for DBGP-based debugging

    Usage:
        pydbgpproxy -i IDE-PORT -d DEBUG-PORT

    Options:
        -h, --help        Print this help and exit.
        -V, --version     Print version info and exit.
        -l LOGLEVEL       Control the logging verbosity. Accepted values are:
                          CRITICAL, ERROR, WARN, INFO (default), DEBUG.

        -i hostname:port  listener port for IDE processes
                          (defaults to '127.0.0.1:9001')
        -d hostname:port  listener port for debug processes
                          (defaults to '127.0.0.1:9000')

    The proxy listens on two ports, one for debugger session
    requests, and one for notifications from IDE's or other
    debugger front end tools.  This allows multiuser systems
    to provide a well defined port for debugger engines, while
    each front end would be listening in a unique port.

    Example usage:
        pydbgpproxy -i localhost:9001 -d localhost:9000
