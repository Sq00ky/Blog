---

layout: post

title: Source Zero Con CTF - STL KIller

gh-badge:

- star

- fork

- follow

tags:

- Capture the Flag

- Wireshark

- TCPDump

- Network Miner

- Cyber Security

comments: true

published: true

date: '2022-06-25'

---

Welcome Back Everyone!

Today we're going to be looking at another challenge from the Source Zero Con CTF. This time we'll be looking at one of my favorite challenges - STL Killer. 

Download Link: [STL Killer](https://drive.google.com/file/d/1yOK3UaA7XPtRndNfAfnCXUXhHCPYk4as/view)

This challenge is a PCAP analysis challenge that involves an attacker compromising a Wordpress Web Server. Let's dive into it!

### Exploitation Questions
The first set of questions revolve around situational awareness - what's happening, the exploitation of the device and more.

Let's start out by doing a bit of data visualization and see what hosts we have.

![[Pasted image 20220625001608.png]](https://blog.spookysec.net/img/Pasted image 20220625001608.png)

Looking at EtherApe and Network Miner it appears there are two primary hosts we are dealing with; 192.168.80.1 and 192.168.80.128.

Expanding out the Host Details in Network Miner, we can see the host has several different User Agents.
- Mozilla/5.0 (Windows NT; Win64; x64 rv:96.0....)
- python-requests/2.22.0
In addition, it appears to be running a Web Server.
- Python3's SimpleHTTPServer.
This device also appears to have one set of ports open (based on the PCAP Communications)
- TCP/8000

On the opposite side of the coin, 192.168.80.128 has one known User Agent.
- Wget/1.20.3 (linux-gnu)
This device only has one Web Server Banner
- Apache/2.4.41 (Ubuntu)
Lastly, this device appears to have one port open.
- TCP/80

From this high level overview, it appears that 192.168.80.1 is the attacker machine and 192.168.80.128 is the victim. We can validate this by doing a bit of manual PCAP analysis. Let's hop over to Wireshark and apply the ``http`` filter.

![[Pasted image 20220625002439.png]](https://blog.spookysec.net/img/Pasted image 20220625002439.png)

A high level overview seems to be that 192.168.80.1 is the attacker and 192.168.80.128 is the victim. Based on some of the info in the Info section in Wireshark, we can see some info about the HTTP Requests. We have a good starting point - 3d-print-lite and what appears to be an arbitrary file upload vulnerability. Let's pop this into Google and see what we can find.

![[Pasted image 20220625002715.png]](https://blog.spookysec.net/img/Pasted image 20220625002715.png)

The first few Google search results show that there is indeed an Arbitrary File Upload vulnerability in the 3DPrint Lite Wordpress Plugin. So far we have the following answers:

| Question | Answer |
|----------|----------|
|What's the attacker's IP?|192.168.80.1|
|What's the victim's IP?|192.168.80.128|
|What's the version of the vulnerable software exploited?|1.9.1.4|

### Backdoors and Enumeration
Moving onto the next section, we're going to have to do a bit of actual PCAP analysis to reveal the details of the attack. Looking at the POC, it appears the arbitrary file upload vulnerability exists within the admin-ajax.php file with the action of p3dlite_handle_upload.

![[Pasted image 20220625004125.png]](https://blog.spookysec.net/img/Pasted image 20220625004125.png)

Looking at TCP Stream #7, we can see a POST request to ``/wp-admin/admin-ajax.php?action=p3dlite_handle_upload``.

![[Pasted image 20220625004312.png]](https://blog.spookysec.net/img/Pasted image 20220625004312.png)

The file uploaded appears to be a file named ``b374k.php``. This appears to be a Web Shell maintained by b374k on [GitHub](https://github.com/b374k/b374k). Looking back at the POC, it appears that this file will be uploaded to ``/wp-content/uploads/p3d/b374k.php``. 

Searching throughout some more TCP Streams, it appears that Stream #9 contains some information about the attacker interacting with the Web Shell.

Following the HTTP Stream gives us a nice chunk of HTML.

![[Pasted image 20220625004832.png]](https://blog.spookysec.net/img/Pasted image 20220625004832.png)

Let's use an [online HTML parser](https://codebeautify.org/htmlviewer) to clean this up a bit.

![[Pasted image 20220625004936.png]](https://blog.spookysec.net/img/Pasted image 20220625004936.png)

Much better! It appears we're sitting in ``/srv/www/wordpress/wp-content/uploads/p3d/``. This is a suprisingly sophisticated Web Shell! It appears the user the attacker has compromised is www-data. This gives us a couple more answers to work with.

|Question|Answer|
|-|-|
|What was the name of the first backdoor uploaded?|b347k.php|
|What was the username of the initial shell?|www-data|

### Privilege Escalation
The next sets of questions revolve around the attacker elevating privileges on the target machine.

Continuing our investigation, It appears the actor read ``/etc/passwd``.

![[Pasted image 20220625005325.png]](https://blog.spookysec.net/img/Pasted image 20220625005325.png)

There seems to be another users on the machine - ``web_dev``. Let's see if the attacker interacts with that user account more.

![[Pasted image 20220625005435.png]](https://blog.spookysec.net/img/Pasted image 20220625005435.png)

It appears that the attacker has moved over to reading the Wordpress Database Config file. The attacker may be searching for password re-use and has located a cleartext password - ``BlueBerry!2021``.

![[Pasted image 20220625005705.png]](https://blog.spookysec.net/img/Pasted image 20220625005705.png)

The next snippet, it appears the attacker is uploading and executing a Reverse Shell.

![[Pasted image 20220625005825.png]](https://blog.spookysec.net/img/Pasted image 20220625005825.png)

We can see the attacker specified a Perl Bind Shell over port 13123 and has a password of b374k. Let's try to find the traffic by applying a filter of ``tcp.port == 13123``.

![[Pasted image 20220625005950.png]](https://blog.spookysec.net/img/Pasted image 20220625005950.png)

We have a considerable amount of traffic here! Let's follow the TCP Stream!

![[Pasted image 20220625010339.png]](https://blog.spookysec.net/img/Pasted image 20220625010339.png)

There appears to be reverse shell comms in cleartext. Nice! Analyzing the conversation, it appears that the attacker attempted to read the Web Developers SSH keys. The attacker then attempted to use the database password to access the ``web_dev``'s user account. The credentials re-use worked. The attacker then ran ``sudo -l`` to list all of binaries that ``web_dev`` could run as root. Vim was one of those binaries, so it was incredibly trivial to elevate privileges with ``sudo vim, enter, esc+:!/bin/bash``, giving the attacker a root shell.

This answers several more questions for us:
|Question|Answer|
|-|-|
|What was the database password?|BlueBerry!2021|
|What was the name of the second user?|web_dev|
|What's the name of the binary used to leverage the privesc to root?|vim|

### C2 Operations
The next question set revolves around Command and Control + Gaining Persistence. After the attacker gained Root access, it appears that the attacker has downloaded a Binary from their Web Server called ``anacrond``.  Anacrond is normally a task scheduling utility, so it wouldn't be suprising to see this file as a scheduled task. Maybe only if you didn't set it...

![[Pasted image 20220625011354.png]](https://blog.spookysec.net/img/Pasted image 20220625011354.png)

So, it appears that the attacker setup a scheduled task to run approximately every 30 minutes.

![[Pasted image 20220625011342.png]](https://blog.spookysec.net/img/Pasted image 20220625011342.png)

At the 30 minute mark, we can see an HTTP request go out to ``http://192.168.80.1:8000/anacrond``.

![[Pasted image 20220625011505.png]](https://blog.spookysec.net/img/Pasted image 20220625011505.png)

This gives us the last few question answers. It appears the PCAP was shaved a few packets short of being able to answer all of the questions; however, our team happened to have the full PCAP from a previous CTF...

This gives us the final answers of:
| Question | Answer |
|----------|----------|
|What's the attacker's IP?|192.168.80.1|
|What's the victim's IP?|192.168.80.128|
|What's the version of the vulnerable software exploited?|1.9.1.4|
|What was the name of the first backdoor uploaded?|b347k.php|
|What was the username of the initial shell?|www-data|
|What was the database password?|BlueBerry!2021|
|What was the name of the second user?|web_dev|
|What's the name of the binary used to leverage the privesc to root?|vim|
|What's the full URL of the backdoor added from the root user?|http://192.168.80.1:8000/anacrond|
|What's the delay between each time the backdoor was to be run?|30 Minutes|

I hope you enjoyed the analysis of this writeup. I'll continue posting the rest tomorrow.

Love, Spooks~
