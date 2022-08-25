---

layout: post

title: Deceiving Bloodhound - Remote Registry Session Spoofing

gh-badge:

- star

- fork

- follow

tags:

- Windows

- Rubeus

- Cyber Security

- Deception

comments: true

published: true

date: '2022-08-24'

---

Hello Everyone!

Today we're back with another blog post in the Deception in Depth series. Recently, I've found a new way to spoof user sessions using Windows' Remote Registry feature. Before we begin talking about how to spoof a user session using this method, we first have to understand *how* SharpHound performs Session Enumeration.

## SharpHound Session Enumeration

There are primarily three different ways that SharpHound performs Session enumeration. Here's quick breakdown for all three:
1. [NetSessionEnum](https://docs.microsoft.com/en-us/windows/win32/api/lmshare/nf-lmshare-netsessionenum) - Enumeration is done via Win32 API calls. Moderately accurate. This information is considered privileged as of Windows 10 v1607+ and Server 2016+.
2. [NetWkStaUserEnum](https://docs.microsoft.com/en-us/windows/win32/api/lmwksta/nf-lmwksta-netwkstauserenum) - Enumeration is done via Win32 API calls. Most accurate. This information is privileged and always requires Admin to collect.
3. [RegistryKey.OpenRemoteBaseKey](https://docs.microsoft.com/en-us/dotnet/api/microsoft.win32.registrykey.openremotebasekey?view=net-6.0) .NETv6 Method - Ability to read the remote registry on the victim system(s). This feature is generally not enabled by default.

### A Quick Look Into the Past

So far we've managed to tackle the first method by using the CreateProcessWithLogonW and a specific flag within that Win32 API that does not attempt to validate credentials against Active Directory. There is one important thing to note; If you call this program as an Administrator, it will run with the privileges of the caller. This is immensley useful for us, knowing this, we can make a call to ``net use \\localhost\c$`` (or something like that) to create an artificial SMB session.

This is a relatively complicated approach, but is super effective. You can read my Blog post about it [here](https://blog.spookysec.net/DnD-SMB-Session-Spoofing-Improved/).

## Another Day Another Method
As I described earlier, this new method leverages Windows' Rmote Registry. Option 3 performs a call to the Remote Registry service running on another device to list all of the entries in HKEY_USERS. This is where user profile data is stored during a logon session, another fun fact is that this data is **only** loaded during a logon session, and at no other time. After the session is finished, or the computer is shut down, the profile is flushed from the registry. This introduces an opportunity for us; We can create a new scheduled task *or* service to create a registry key under HKEY_USERS.

### Trial and Error
Ok - Confession time, I made this sound a lot easier than it actually is... Going into the Registry, right clicking and adding a new key under ``HKEY_USERS`` doesn't actually work... 
![[Pasted image 20220824210010.png]](https://blog.spookysec.net/img/Pasted image 20220824210010.png)
![[Pasted image 20220824210020.png]](https://blog.spookysec.net/img/Pasted image 20220824210020.png)

:(

Plan foiled... But wait; If Windows loads a profile when a user logs on, surely there must be a way! And, well, there is! Have you ever noticed that file in your folder "NTUSERS.DAT"? Well, it turns out that file can be loaded into the registry. 
It stores all of your preference settings and a ton more! It's not a really well documented file structure, so I'm not going to pretend like I know what I'm talking about, *but*, it turns out that you can load this into the registry with the ``reg load`` and ``reg unload`` command! So let's give it a shot.

![[Pasted image 20220824210500.png]](https://blog.spookysec.net/img/Pasted image 20220824210500.png)

So close! Lets try running this as an Administrator...

![[Pasted image 20220824210547.png]](https://blog.spookysec.net/img/Pasted image 20220824210547.png)

Well thats certainly a different error! Let's try loading an *inactive* NTUSER.DAT file from another users account....

![[Pasted image 20220824210701.png]](https://blog.spookysec.net/img/Pasted image 20220824210701.png)

Well, it appears its loaded! Lets check regedit.

![[Pasted image 20220824210736.png]](https://blog.spookysec.net/img/Pasted image 20220824210736.png)

### Great Success - Demo Time

There it is! Our custom SID. Now that we have a working POC for loading SIDs, let's select a *real* Domain Admin SID and start the Remote Registry service.
To dump all the sids in the Domain, we can use ``wmic useraccount get name,sid``.

![[Pasted image 20220824210946.png]](https://blog.spookysec.net/img/Pasted image 20220824210946.png)

Afer executing it, we can see there are some new Domain Admins on the block! Let's simulate a session for *da-richard* on this workstation. To do so, we must copy their SID (S-1-5-21-3765047370-2075063925-905232779-6064) and load the NTUSERS.DAT registry hive. We can do so with the following command:

```
reg load HKU\S-1-5-21-3765047370-2075063925-905232779-6064 .\NTUSER.DAT
```

![[Pasted image 20220824211154.png]](https://blog.spookysec.net/img/Pasted image 20220824211154.png)

And there it is, da-richard's SID loaded into the registry. Let's start the Remote Registry service through ``services.msc``.

![[Pasted image 20220824211508.png]](https://blog.spookysec.net/img/Pasted image 20220824211508.png)

Ensure that the service start type is set to Automatic and is started. Once this is complete, the Remote Registry service should be running. One last thing worth noting - The Remote Registry service will stop if there is no activity on the workstation for some time, there is a registry key that must be updated for it to run 24/7.

**Key Name:** HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\RemoteRegistry
**Value:** DisableIdleStop
**REG_DWORD:** 1

One last thing **make sure you disable the Firewall**. By default, the Remote Registry service is filtered and you may not be able to see your session!

### Running SharpHound and Spinning up BloodHound
Now that we have our deception setup, let's pretend that an attacker has compromised a Workstation Admin account and has the ability to collect session data, so in theory, if this deception object was deployed on a production system, an adversary would be none the wiser.

![[Pasted image 20220824213631.png]](https://blog.spookysec.net/img/Pasted image 20220824213631.png)

Next the adversary would load the Data into BloodHound and find their according user and mark them as an Owned principal. 

![[Pasted image 20220824213728.png]](https://blog.spookysec.net/img/Pasted image 20220824213728.png)

Afterwards, they would then search for paths to Domain Admin (more specifically, the shortest path). After executing this query in a relatively clean environment (i.e. No Domain Admins within closer reach) you should see a very short path to DA-Hendrix!

![[Pasted image 20220824213950.png]](https://blog.spookysec.net/img/Pasted image 20220824213950.png)

We can see that our method injected an artifical path to Domain Admin. On *Lab-Wkst-4*, there is a Session for the user *da-hendrix*. We can see that our user (WA_MOORE) is a member of the Workstation Admins group, which is an Administrator on that workstation. This means that Domain Admin *appears* to be one hop away.

## Introducing Honey Sessions
Overall, this is a fairly simple method. There's a lot of room for optimization (in my opinion). So myself and @[LIKEROFJAZZ](https://twitter.com/likerofjazz) have done that. Over the past month or so, we have written a Python script (compiled with PyInstaller) to automatically drop a NTUSER.DAT file to disk and automatically pick a random Domain Admin session to inject.

So... Demo time, again! This time we'll be running BloodHound-Py for the sake of simplicity. 

### Setup
Little to no setup is required, though there are a few constraints:
1. The user must be an Administrator on the Workstation
2. The user must be a domain user (unless you specify a SID)

Simple enough! Now we'll head over to [Honey-Sessions](https://github.com/LIKEROFJAZZ/Honey-Sessions) on GitHub and download the pre-compiled PyInstaller executable. If you have trust issues, the source code is provided as-is. You may feel comfortable substituting in your own ``NTUSER.DAT`` file as well. We promise it's nothing malicious. Just trying to make everyones life easier :D

Anyways - after downloading [HoneySessions.exe](https://github.com/LIKEROFJAZZ/Honey-Sessions/raw/main/HoneySessions.exe) to the Workstation, the next step is super straight forward. Run the binary as an Administrator.

![[Pasted image 20220824215432.png]](https://blog.spookysec.net/img/Pasted image 20220824215432.png)

Don't be silly like me and try to not run it on a medium integrity level, haha. Attempt #2 - Let's try this again.

![[Pasted image 20220824215529.png]](https://blog.spookysec.net/img/Pasted image 20220824215529.png)

This time it actually worked, though it randomly selected da-hendrix again... Let's re-run it and see who we get this time.

![[Pasted image 20220824215604.png]](https://blog.spookysec.net/img/Pasted image 20220824215604.png)

da-richard, much better! Let's run BloodHound.py and load the data into BloodHound!

![[Pasted image 20220824215744.png]](https://blog.spookysec.net/img/Pasted image 20220824215744.png)

We can see immediately that theres a handful of user sessions on Lab-Wkst-2, good news! Let's go check out who they are. As always - Make sure you mark the user as owned and then search for shortest path to Domain Admins!

![[Pasted image 20220824220018.png]](https://blog.spookysec.net/img/Pasted image 20220824220018.png)

And there it is. Plug-n-Play Deception. Anyways - I hope you all enjoyed this entry in the Deception in Depth series. I have absolutely no idea when the next post will come out. I don't have anything hidden up my sleeve, but that doesn't mean I'll stop being passionate about deception. If you'd like to chat with me about Deception, feel free to reach out to me on [Twitter](https://twitter.com/NaisuBanana) or [LinkedIn](https://www.linkedin.com/in/rbartwitz/). I'd love to discuss new ideas, help develop and flesh out new methods, or even give some advice or share some experiences if Deception is something you're interested in bringing to your organization. 
As always - Thank you for all for the love and support <3
~ Ronnie
