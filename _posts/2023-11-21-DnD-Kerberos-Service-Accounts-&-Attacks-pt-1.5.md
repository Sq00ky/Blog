---
layout: post
title: Deception in Depth - Overview of Kerberos, Service Accounts & Attacks - Part 1.5
gh-badge:
  - star
  - fork
  - follow
tags:
  - Windows
  - Cyber
  - Security
  - Deception
  - Active
  - Directory
  - Kerberos
  - Kerberoasting
comments: true
published: true
date: 2023-11-21
---

Welcome back, everyone! 

I sincerely hope you all enjoyed the last post. I wish I had gotten this post out a lot sooner, truth be told I had 3/4 of it written, then scope creep happened. Motivation runs a bit thin in this one when that happens, but that's depressing and we're not here to talk about that! 

In order to get this post out a bit sooner, I've decided it would be best to split this blog post into two parts - Part 1.5, an overview on Kerberos, Service accounts, and Attacks, and part 2, Deceptive Service Accounts & Concealing Legitimate Service Accounts.

Today we're going dive back into the realm of theory, we're going to skip deception in this post and come back to it in the next. This will let people who have a good understanding of Service Accounts, Kerberos, etc. skip it and move onto deception! 

I'd like this post to be a bit more structured since the last post was a bit more investigative and research driven (given its type of post). So, let's do what any good structured post does and outline some sections!
### Sections
This post will be broken into 5 different sections:
- What are Service Accounts
- Kerberos Authentication and Encryption Types
- Attacks Against Kerberos (and Service Accounts)
- Lab Setup and Kerberoasting Demo
- Closing Thoughts

### What are Service Accounts
You may have heard the term "Service Account" thrown around before by your identity team, but what exactly are them and what do they do? This simple question has a rather complicated answer.

We can take the literal definition of a service account, that being "It is a specific account that is used to run a certain service on a Windows Workstation or Server within an Active Directory environment". This may be required when a specific service may need permissions to do something on the network that extends beyond the computer that the service is installed on. 

A good example of this would be Privileged Identity Management software like CyberArk. A subset of CyberArk is password rotation - In order to accomplish this, CyberArk requires an account within Active Directory that has permissions delegated to it to change a user accounts password. 

The functional purpose purpose of a service account has extended far beyond that in the modern day. It can be as simple as being a dedicated account on a Linux server to query LDAP within a web application to check and see if a user is a member of a specific group and can extend out from there.

Okay, so what actually are service accounts? They're just normal user accounts that may be delegated some special type of permission in AD. Sometimes this may be over another object (or group of objects), or sometimes this may be used in a process. Generally speaking, what makes a service account a service account can vary from environment to environment. 

And we haven't even talked about Service Principal Names yet! Okay - So, when you're installing an application that will require a full fledge service account, the installation process will *sometimes* create something called a SPN (or Service Principal Name). You can read about the [programmatic SPN registration process in Active Directory here](https://learn.microsoft.com/en-us/windows/win32/ad/how-a-service-registers-its-spns). But what exactly does a SPN do? Great question. A SPN can enable Windows' implementation of Kerberos Authentication. There's some magic that Microsoft describes as to how it actually works, I'll do a bit of paraphrasing, but they really explain it best.

So, you want to be eligible for secure authentication (Plug for killing NTLM) using Kerberos? You gotta get a SPN. I think it helps if we use an example here, let's say we have a server - SQL01 and it's running MSSQL on TCP port 1433. Kerberos requires that we register this so clients can find our server/service and know that Kerberos Authentication is supported. So, why would we want to use Kerberos over alternatives? That brings us to our next topic.

### Kerberos Authentication and Encryption Types
So, why would we want to use Kerberos over an alternative? First, it helps to understand what exactly our alternatives are and why Kerberos is objectively better. We have one or two other alternatives, really only one. Those being:
- NTLM Authentication
- Local Authentication

Local Authentication is out of the question for many reasons, the most basic is it adds complexity to managing user accounts within the environment. We go from centrally managed IT Infrastructure to bleh - credentials scattered everywhere. We want someone else to validate and manage identities, not us!

If you know anything about the current state of Windows-land, Microsoft is trying **really** hard to kill NTLM and NTLM authentication right now. NTLM authentication is subjected to relaying attacks and weak challenge-based authentication methods (we'll do benchmarks on the difference in hash cracking speed in a minute!). Since discussing what a relaying attack is is definitely out of scope for this post, here's few quality resources where you can learn about NTLM relaying.
- [https://en.hackndo.com/ntlm-relay/](https://en.hackndo.com/ntlm-relay/)
- [https://www.thehacker.recipes/a-d/movement/ntlm/relay](https://www.thehacker.recipes/a-d/movement/ntlm/relay)

Aside from relaying, how weak exactly is NTLM Authentication exactly? How much better is Kerberos's Authentication? Kerberos implements stronger encryption algorithms that better protect the users identity. We describe Kerberos as supporting specific eTypes, or Encryption Types. In Server 2022, there are three main encryption types available with some new ones on the horizon (Yay, Quantum Computing!):
- RC4 (eType 23)
- AES128 (eType 17)
- AES256 (eType 18)

There are other legacy encryption protocols (like DES) that have since been deprecated (since Server 2008) that you should be aware exist and may come up in old old old environments. You can still enable some of these today! 

Fun fact, I was once asked about eTypes in an interview and could only think of AES128/256 and DES (of course I could only thing of the deprecated encryption type and choked on RC4). Don't be like me. Know your Kerberos eTypes. They're important and here's why. It's time for our Hash Cracking break!

**Brief Intermission - Hashcat Benchmarks!**

Let's look at some numbers for a second - Using an RTX 4090, we can run a few benchmarks to get a good idea of how much better Kerberos is over NetNTLM. Below is a chart:

|**Hash Mode**|**Encryption Type**|**Cracking Speed**|**Normalized Cracking Speed**|
|---|---|---|---|
|1000|NTLM|267.4GH/s|267,400,000,000 Hashes per Second|
|5500|NetNTLMv1|143.1GH/s|143,100,000,000 Hashes per Second|
|5600|NetNTLMv2|11.1GH/s|11,075,500,000 Hashes per Second|
|13100|RC4|3.1GH/s|3,145,300,000 Hashes per Second|
|19600|AES128|4.8MH/s|4,845,600 Hashes per Second|
|19700|AES256|2.4MH/s|2,407,200 Hashes per Second|

We can see there is a massive difference in cracking speed on the highest end GPU that you can currently buy. AES256 is 4,600x slower to crack than NetNTLMv2.  To put this into a real world perspective - Using the HIBP-v8 from hashmob, a Service Account using **AES256** encryption took **7 minutes 26 seconds** to crack whereas **NTLM** took **20 seconds**. In this real world case, NTLM was approximately 22x faster. What a difference, no wonder why Microsoft suggests we move away.

**Intermission Concluded - Kerberos Authentication**

No authentication mechanism is perfect, and that includes Kerberos - To understand the primary attack on Service Accounts, we must first have a good understanding of how Kerberos Authentication works. We discussed some of the core components earlier, but how exactly does the authentication flow work? What's exchanged at each step? Let's dive into it.

There's a major background component that you should be aware that exists on your Domain Controllers, this being the service that actually runs Kerberos - The (Kerberos) Key Distribution Center. This service is responsible for crafting Kerberos tickets that clients will use to authenticate to a given server/service. So, how exactly does Kerberos authentication work?  This flow is broken up into four unique steps:

1. A client would like to authenticate to a service, so it reaches out to the Domain Controller with a AS-REQ (Authentication Service Request).
	1. This request includes the supported eTypes (in the event an unsupported eType is initially provided). 
	2. This also includes a solution to a challenge that proves the users identity. 
2. The Domain Controller / KDC service decrypts the challenge in the AS-REQ ticket and validates the identity. The KDC issues an AS-REP Ticket (Authentication Service Reply)
	1. Portions of the ticket are encrypted with the KRBTGT user accounts password as a means for the KDC to validate the tickets authenticity at a later date
3. The client then reaches back out to the Domain Controller letting it know "Hey, I have a specific service that I would like to authenticate to!" - this is done by a TGS-REQ (Ticket Granting Service Request)
	1. This includes the Service Principal Name and the protocol it would like to authenticate to.
	2. The previously encrypted ticket is also included as a way to validate that this came from the user as a means of authentication to the KDC
4. The Domain Controller/KDC replies with a TGS-REP (Ticket Granting Service Reply)
	1. The ticket returned is partially encrypted with the Service Account's password

That pretty much covers the authentication flow from the Client to the DC. From this point on, the client and server no longer need the Domain Controller to intervene. The client can pass the ticket over to the service that it would like to authenticate to. The service can then decrypt the contents of the ticket and validate the identity (like previously stated) without requiring the Domain Controller. Pretty straight forward! 

I originally had a section in here about WireShark and the authentication flow that occurs there, in order to keep the post on the short side, I'm going to exclude that section and give you all a PCAP, which [can be downloaded here](https://blog.spookysec.net/krb.pcap). I'd encourage you to go explore it using what you learned above. 
### Attacks on Kerberos (and Service Accounts)
Now that we have a better understanding of Kerberos' Authentication mechanism, we can introduce an interesting technique developed by Tim Medin called "Kerberoasting". You may recall we have to have an SPN registered for Kerberos authentication to occur, keep this in the back of your mind.

During Stage 4 of the authentication process, you may recall that the Key Distribution Center gives us a TGS (Ticket Granting Service) back which we then present to the Server that we're trying to connect to. Well, the Service knows this is genuine, how does it know this? Well, it turns out, it's encrypted with the Service Accounts NTLM hash. The KDC does this so the service account can handle some step of the authentication process to reduce the load on the Domain Controllers. It's actually super clever. So, the goal behind Kerberoasting is cracking trying to crack the machine accounts NTLM hash out of the encrypted ticket. 

So you may have a question - why can we only Kerberoast accounts with SPNs? This is a good question - We can only do it because there is a service registered to that account. If there was no SPN, the KDC wouldn't hand us a Service ticket. If you can somehow create a SPN on that user account, you could theoretically Kerberoast it. In fact, that's a completely valid attack vector over a user account. If you have GenericWrite privileges and don't want to upset the way of the land, you could create a SPN over the user and attempt to crack it's password via Kerberoasting. Magic!
## Lab Setup & Kerberoasting Demo

### Lab Setup

It's important that we setup a control group in our AD lab, so we can understand how Kerberoasting works. In the next post, when we dive into Deceptive Service Accounts, it'll make everything a lot more clear. Configuring and setting up Service Accounts will be necessary for the next post. 

So, in the real world, SPNs get magically created via the Service (or at least it does in the case of MSSQL). Since I'm sure not all of you have MSSQL, or, or don't want to pose a risk to a real MSSQL instance, we're going to create a new "Service Account" in our AD lab and assign a SPN using the ``setspn.exe`` binary. Let's dive in (Fun fact: if you take a shot every time I use that sentence, it's a lot easier to get through my ramblings).

If you've never setup an Active Directory lab, it's super easy! I have a series starting with [Part 1 here](https://blog.spookysec.net/ad-lab-1/) and [Part 2 here](https://blog.spookysec.net/ad-lab-2/).  If you've already got one, we'll start with our user account creation. You can create a new user by opening the Active Directory Users & Computers management console; Afterwards, you'll want to create/find an appropriate OU for our Service Account to live in. For the lab, I have an OU named Accounts and Sub-OUs for each account type. So, in the Service Accounts OU, I'll right click, select New, then User.

![[https://blog.spookysec.net/img/Pasted image 20231115005926.png]](https://blog.spookysec.net/img/Pasted image 20231115005926.png)

We'll call it "svc-sqlmagic" for fun. Clicking "Next" will prompt us for a password; Set it to something trivial to crack. My go-to passwords for lab is pretty much just P@ssw0rd123!. It meets most if not all complexity requirements, is pretty easy to remember and type. Click next again, make sure your password was typed in and finish up the account creation. Now for the fun stuff! In my lab (I already mentioned this), I have MSSQL setup with a legitimate service account. We can use the ``setspn.exe`` command to enumerate an existing Service Account and see what kind of SPN MSSQL creates by default. We can do this with ``setspn -L serviceaccountname``.

![[https://blog.spookysec.net/img/Pasted image 20231115010256.png]](https://blog.spookysec.net/img/Pasted image 20231115010256.png)

There appears to be two distinct values - MSSQL/SQLSRV.nanaisu.com and MSSQL/SQLSRV.nanaisu.com:1433. The format here is SERVICENAME/hostname.domain.tld and an optional port value. Good easy way to identify potential services without portscanning. Okay, so we can register a new SPN with ``setspn -S service/host.dom.tld user``. So in our case it would be ``setspn -S MSSQLSvc/notmssql.nanaisu.com svc-sqlmagic``. Later, we can go in and create honey-domain joined servers, and build up & out our deceptions, but for now, this should be good. After setting up the SPN, we should now be able to view it with ``setspn -L svc-sqlmagic``. 

![[https://blog.spookysec.net/img/Pasted image 20231115010856.png]](https://blog.spookysec.net/img/Pasted image 20231115010856.png)

Success! The service is now registered within the KDC. We should be able to request a service ticket for it & crack the password. Let's pivot over to Kali 
### Kerberoasting Demo

There are multiple methods for Kerberoasting - On the Windows side, you've got an awesome c# tool called [Rubeus](https://github.com/GhostPack/Rubeus) that's excellent for manipulating and interacting with Kerberos as a protocol. For PowerShell, there's Invoke-Kerberoast from [PowerSploit](https://github.com/PowerShellMafia/PowerSploit/tree/master/Recon). On the Linux side (which we'll be focusing on today) is the GetUserSPNs.py example script from [Impacket](https://github.com/fortra/impacket/tree/master).  Setup and installation instructions are provided on the repo (or you can just clone the repo, CD into it and run ``python3 setup.py install``). After that's finished, it's as simple as  running ``GetUserSPNs.py -request domain.com/user:'P@ssw0rd123!'`` and watch the hashes roll in!

![[https://blog.spookysec.net/img/Pasted image 20231115015028.png]](https://blog.spookysec.net/img/Pasted image 20231115015028.png)

It's now as simple as using the Hashcat wiki to identify if an RC4, AES128 or AES256 hash was pulled back, so you've got the required hashmode. We'll pivot over to the hashcracking rig and begin the hash cracking process! In our case an eType 23 TGS-REP hash was pulled back. So, our hashcat command will look something like so:

```
hashcat -m 13100 -a 0 .\hash.txt ..\worldlists\rockyou.txt -r ..\rules\onerule.rule
```

After that, it's off to the races!

![[https://blog.spookysec.net/img/Pasted image 20231115014017.png]](https://blog.spookysec.net/img/Pasted image 20231115014017.png)

Give Hashcat a few moments and it successfully cracked our super weak password. We've successfully compromised our control service account!

### Closing Thoughts

That concludes part 1.5 of the Kerberos, Service Accounts & Attacks blog post. To summarize we've talked about what service accounts are, what makes them a service account, Kerberos as an Authentication protocol, a little bit about the Encryption Types it supports, and covered a super common attack called Kerberoasting. 

See you in the next post!

<img src="https://blog.spookysec.net/img/beautiful-time-bye.gif">
