---
layout: post
title: Remote NTLM Relaying via Meterpreter
gh-badge:
  - star
  - fork
  - follow
tags:
 - TryHackMe
 - Windows
 - Active Directory
 - Cyber Security
comments: true
published: false
date: '2020-12-13'
---

### NetNTLM Relaying basics
NTLM Relaying is an Active Directory attack vector that commonly makes use of Man-In-The-Middle tools like Responder, MITM6, and others to intercept Active Directory protocols like SMB, HTTP, LDAP, etc to hijack a session and "relay" or redirect the intercepted session to the target host of your choise. 
It's important to understand that NetNTLM uses a challenge based request and response system, so you cannot replay NetNTLM traffic, only relay it. In order to Relay NetNTLM-Based traffic the Impacket developers have created a special tool called NTLMRelayX. NTLMRelayX brokers communications on our behalf and manages the challenge based request and response that enables us to successfully authenticate to a Server. It does so by holding the <insert protocol> session open and proxies the challenge that the server issues to the client, but never closes the session so you can authenticate to the server on an on-demand basis. In order to enable this functionality, you need to use the "-socks" flag, but by default, it will simply it will simply make use of other Impacket tools (like SecretsDump.py, if you relay to SMB, ACLPWN if you relay to LDAP/S, etc) but that's beyond the scope of what this article is trying to acomplish today. This seems really complicated, but is actually quite simple. I promise, I'm just bad at explaining overly technical topics. Impacket does a great job with documentation, if you'd like to learn more about NTLMRelayX, you can do so here: [https://blog.fox-it.com/2017/05/09/relaying-credentials-everywhere-with-ntlmrelayx/](https://blog.fox-it.com/2017/05/09/relaying-credentials-everywhere-with-ntlmrelayx/).

### Remote N.T.L.M. Relaying

I deem this attack vector called Remote N.T.L.M. Relaying (Never Trust Lan Man) purely because of how severe it can be. If you execute this attack on the correct host, Remote NTLM Relaying can incredbibly disruptive. This attack vector can be used on virtually any Windows host of your choosing as long as you have local Administrative rights, however, I suggest the primary target to be File Servers because these will gain the most traction. Lots of File Server Shares are often auto-mounted via Startup Scripts when a user logs onto their Account, this making it the best option in my opinion. If all users in an AD Domain have a folder that auto-mounts, you simply need to compromise the File Server, gain local Administrative Rights, and execute this attack and play the waiting game for a Domain/Enterprise Admin to log into their account and then it's game over.

### Initial Warning

As previously stated, this attack vector is incredily distruptive. It requires exactly 1 OS Restart to disable Active Directory services, and 1 OS Restart to re-enable them. If you are going to use this attack vector on an engagement, make sure you have **explicit authorization from the client**. Responsibility soley lies on the Attacker, and not myself. This is your official "This can break things, I take no responsibility for what you do. Lab it before you try it, understand the risks" and yada yada. 

### How To Preform Remote N.T.L.M. relaying

Anyways, onto the good stuff. With normal NTLM Relaying, insure you have a target selected that does not require Signing (We're going to use SMB in this demo, so I will here-on in refer to this as SMB signing exclusively). Secondly, ensure Impacket, NTLMRelayX, Meterpreter and Proxychains are all installed. All will be required for Remote NTLM relaying.
