---

layout: post

title: Analyzing a Brute Ratel Badger

gh-badge:

- star

- fork

- follow

tags:

- Malware Analysis

- Command and Control Frameworks

- Brute Ratel

- Windows

- Cyber Security

comments: true

published: true

date: '2022-07-09'

---

Now a days [Brute Ratel](https://bruteratel.com/) (sometimes called the "Angry Monkey C2") seems to be a hot topic within the information security community. There's been lots of drama surrounding the author ([ParanoidNinja](https://twitter.com/NinjaParanoid)), rumors of the C2 being backdoored, and even some [blog posts](https://unit42.paloaltonetworks.com/brute-ratel-c4-tool/) from well known and respected individuals within the security community indicating that the C2 framework is potentially being used by APT29 (aka the Russian State Sponsored groups).

So, with all these controversies, where do we go from here? Well, validating the claim that the C2 Framework is backdoored can be quite difficult to prove as that would involve me spending several thousand dollars to acquire the framework itself... So, that's not exaclty feasable. I can however get the next best thing. A Brute Ratel Beacon, or Agent (or as they like to call it, a "Badger").

## Acquiring a Badger for Analysis
How can we do this exactly? Fortunately, I have a VirusTotal Enterprise license! This means we can pull down (download) a publicly tagged "Brute Ratel" sample from the community. To do so, we're going to use a search for something like ``Comment:"Brute Ratel"`` and see if we get any hits...

![[Pasted image 20220709143536.png]](https://blog.spookysec.net/img/Pasted image 20220709143536.png)

Suprise Suprise, we got six hits! Let's go with the most obvious one, [badger_x64.exe](https://www.virustotal.com/gui/file/3ad53495851bafc48caf6d2227a434ca2e0bef9ab3bd40abfe4ea8f318d37bbe) (SHA256 Sum: 3ad53495851bafc48caf6d2227a434ca2e0bef9ab3bd40abfe4ea8f318d37bbe). 

## Lab Setup
For this lab, we will be using REMWorkstation + REMnux. Here's a diagram that breaks down the lab setup:

![[Untitled Diagram.drawio.png]](https://blog.spookysec.net/img/Untitled Diagram.drawio.png)

- REMWorkstation has the IP Address of 192.168.128.12
- REMNux has the IP Address of 192.168.128.10
- Default Gateway has the IP Address of 192.168.128.2
- REMNUx **can** route to 192.168.128.2, but the route is not configured.
- If REMNux is configured to route to the Default Gateway, outbound  traffic to the internet **is** allowed

In addition:
- REMNux will have an iptables rule that will accept all and any traffic going into it.
- REMNux will be running FakeDNS and iNetSim
- REMNux will be running WireShark
- REMWorkstation will be running Fiddler

And thats our lab! 

## Dynamic Analysis - Malware Detonation
Now that we have our sample acquired, and you're familiar with my lab setup, let's double click some EXEs!

![[Pasted image 20220709151411.png]](https://blog.spookysec.net/img/Pasted image 20220709151411.png)

So, right off the bat, we can see some beacons to 156.65.186.50 over HTTPS. Looking at these requests in Fiddler, we can see that the sample is using the user agent: ``Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36`` with no extra headers.

![[Pasted image 20220709151806.png]](https://blog.spookysec.net/img/Pasted image 20220709151806.png)
This is suprisingly bare. Let's pivot over to iNetSim and see whats going on over there.

![[Pasted image 20220709152048.png]](https://blog.spookysec.net/img/Pasted image 20220709152048.png)

On that side, we can see a little bit more. The file that the "Badger" requested is ``/admin``, and there is also some POST data that we missed!

Let's see if we can find that in Fiddler... Unfortunately, I could not find the request in Fiddler, I'll have to revert and redetonate the sample in a bit... 

Edit: Fiddler actually caused some issues w/ cutting the POST data off to inetsim :(.

### Procmon/ProcDot Analysis
For now - Let's move over to ProcMon and ProcDot and see what the badger is looking for.

![[Pasted image 20220709152935.png]](https://blog.spookysec.net/img/Pasted image 20220709152935.png)

Starting out, this is an absolutely massive graph. Let's start from the top and work our way down.

At the top:

![[Pasted image 20220709153041.png]](https://blog.spookysec.net/img/Pasted image 20220709153041.png)

It appears that the badger is first checking to see if there are any registry keys correlated to a proxy on the system. Since no proxies are in place, BRC4 likely foudn nothing.

On the far right, we can see a couple of cached web page responses saved to disk. If you'd like to read that data - all it contains is the iNetSim HTTP Response.

![[Pasted image 20220709153734.png]](https://blog.spookysec.net/img/Pasted image 20220709153734.png)

Moving on down the graph, we can see another read attempt on another registry key relating to proxies:

![[Pasted image 20220709153819.png]](https://blog.spookysec.net/img/Pasted image 20220709153819.png)

One interesting thing I'd like to point out is the Badger is leveraging a bunch of ThreadCreates and ThreadOpens to potentially confuse AV or EDR.

Zooming out, all the black diamons are all new threads and Thread ID Numbers.

![[Pasted image 20220709153956.png]](https://blog.spookysec.net/img/Pasted image 20220709153956.png)

Scrolling down a bit more, this pattern continues. More Threads being created to read registry keys relating to proxies:

![[Pasted image 20220709154108.png]](https://blog.spookysec.net/img/Pasted image 20220709154108.png)

### Back to iNetSim

Now that we know a bit more about what the program is trying to do, let's go back to iNetSim and read the POST data from the Web Server.

All of the POST data is stored in ``/var/lib/inetsim/postdata/*``. I hope that helps someone in the future... :)

![[Pasted image 20220709160032.png]](https://blog.spookysec.net/img/Pasted image 20220709160032.png)

Let's bring the input into CyberChef and decode the Base64.

![[Pasted image 20220709160124.png]](https://blog.spookysec.net/img/Pasted image 20220709160124.png)

### Searching for Encryption in APIMonitor

Interesting! The POST Data is encrypted. I think I know a trick or two that could help us decode this. To do so, we'll need to hop into API Monitor and hook into the process and observe the API Calls the badger is performing. We're looking for a call to Microsoft's Cryptographic API *or* a call to the HTTP APIs as we know some cryptographic function performs before the POST data is sent...

![[Pasted image 20220709161445.png]](https://blog.spookysec.net/img/Pasted image 20220709161445.png)

By searching for a common Windows API (RtlUTF8ToUnicodeN), we can quickly find where some data conversion is taking place to give us a good starting point of reference.

![[Pasted image 20220709161701.png]](https://blog.spookysec.net/img/Pasted image 20220709161701.png)

Looking at the CallStack, we see some lovely Windows API calls that look very close to what we need. Since some sort of technique is being used to dynamically resolved the APIs needed is being used, let's back off of APIMonitor and move over to a Debugger.

### Pivoting to x64Dbg

I have setup x64Dbg to use counter-antidebugging techniques using ScyllaHide, so if there are any techniques implemented, we won't have to worry about them.

After letting the program run for a while, I set a breakpoint on a couple of the common HTTP APIs. We got a hit on InternetOpenW; in my suprise, in the stack window, here we are. We have the unencrypted data starting at us!

![[Pasted image 20220709212027.png]](https://blog.spookysec.net/img/Pasted image 20220709212027.png)

It appears to be some JSON that looks like so:
```json
"desktop-2c3Iqh0",
	"wver":"x64/10.0",
	"arch:"x64",
	"bld":"16322",
	"p_name":"<base64 blob>",
	"uid":"REM",
	"pid":""
}
```
The Base64 glob is still relatively interesting to me, p_name, could this mean program_name? Let's decode it!

![[Pasted image 20220709212302.png]](https://blog.spookysec.net/img/Pasted image 20220709212302.png)

It appears so! I set a BreakPoint earlier in the stack and let the execution flow to see if I could extract any more information from the Badger, doing so did yeild some extra results!

![[Pasted image 20220709212945.png]](https://blog.spookysec.net/img/Pasted image 20220709212945.png)

We have an auth token now and a more complete JSON blob.

```json
{
"cds": {
	"auth":"2K4TBS7L9GK2C205"
	},
"mtdt": {
	"h_name":"DESKTOP-2C3IQH0",
	"wver":"x64/10.0",
	"arch":"x64",
	"bld":"16322",
	"p_name":"<base64 blob>",
	"uid":"REM",
	"pid":""
	}
}
```

Unfortunately, our analysis stops here as we don't have a live C2 server to observe interactions with. Though, we could explore *how* the badger interacts with the C2 server if we carefully observe how the badger parses the response from the C2 server. There is definately some hardcoded commands that we would be able to use to manipulate the badger itself with iNetSim.

I would have liked to have caught the Windows API that actually encodes/encrypts this data, so I could write a small decoder for the information if you have the badger; but it appears that wasn't meant for tonight :(

## Basic Static Analysis
So, this section is going to be much shorter than the last, as I've already found the interesting C2 related data; Now, we're going to play an interesting game of "How good is Brute Ratel's Obfuscation Techniques"! The answer isn't very good.

To start, we're going to chuck the EXE into Cyberchef and look at some of the clear text ASCII values.

![[Pasted image 20220709221750.png]](https://blog.spookysec.net/img/Pasted image 20220709221750.png)

### HTTP Request Information
So, right off the bat, it's not looking so good. We can see a **lot** of interesting strings; we can see a lot of the HTTP POST information broken up into various strings. For example:
- /logi
- AppleWeb
- Kit/537
- 65.186.5
- 159
- 443

Some of these strings are incredibly meaningful! For example, putting together the bits 159.65.186.50 gives away our command and control server, and 443 gives away the port! How interesting...

### Windows APIs
Looking a little bit lower, we can see some of the Windows APIs the program uses as well. They appear to be jumbled up, but still readable to the human eye.

![[Pasted image 20220709221944.png]](https://blog.spookysec.net/img/Pasted image 20220709221944.png)

- VirtualProtect
- GetLastError
- GetModuleHandleW
- GetProcAddress

The more you keep looking, the more you see the pattern.

### HTTP POST Data
Interestingly enough, you can actually find a lot of the HTTP POST Data that we had to work oh so hard to reverse engineer to find...

![[Pasted image 20220709222246.png]](https://blog.spookysec.net/img/Pasted image 20220709222246.png)

- arch
- bld
- fname
- h_name

Continuing our search, we may be able to learn more about the badgers capabilities. Looking at the screenshot above, towards the bottom, we can make out "Download Failed". Perhaps this badger has the ability to upload files to the server? Let's keep digging.

![[Pasted image 20220709222528.png]](https://blog.spookysec.net/img/Pasted image 20220709222528.png)

### Badgers like LDAP! 
It looks like the badger uploads PNG/image files to the C2 server. It also makes some queries to LDAP as well and will communicate with the Global Catalog. If it can't, it'll spit out some binding errors.

![[Pasted image 20220709222736.png]](https://blog.spookysec.net/img/Pasted image 20220709222736.png)

Searching lower down the list, we can see some of the information it collects, like Password Expiration, if the password never expires, and if there is a bad password supplied.

### The Badger is Self Aware?
Continuing our string-hunt, here's one of the most interesting sets of strings... Badger itself is embedded as a string in the binary :facepalm:
![[Pasted image 20220709223019.png]](https://blog.spookysec.net/img/Pasted image 20220709223019.png)

I've already loaded up the binary into Ghidra and there's a whole lot of nothing. It seems to be a bit beyond my skill level to reverse engineer in a classic sense, so I'll have to do some more research on my own time to figure out if I can post a followup showing off the actual binary internals.

## Misc Findings
Here are some interesting things I found that I wanted to include in the post, but couldn't easily write into the flow of the post. I still think this is worth mentioning.

### Chinese Threat Actor?
Here is an interesting String Compare after executing a HTTP Request; it asppears that this badger is checking to see if some of the response headers contain ``xn--``. I believe this is set when the (potentially) Chinese threat actor generated the implant... More investigation would definitely be needed.
![[Pasted image 20220709213754.png]](https://blog.spookysec.net/img/Pasted image 20220709213754.png)

### Traffic Generation to windowsupdate.com
Another interesting aspect of this badger is that it periodically reaches out to ``ctldl.windowsupdate.com``. I originally thought this was Windows being Windows, but it turns out that this is hardcoded within the binary. This is likely a cloaking mechanism to throw off AV/EDR/Sandboxes.

![[Pasted image 20220709214256.png]](https://blog.spookysec.net/img/Pasted image 20220709214256.png)

I hope you all enjoyed :)
~Ronnie
