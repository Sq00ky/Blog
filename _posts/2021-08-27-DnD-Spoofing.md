---

layout: post

title: Deception in Depth - Spoofing Logged in Users

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

date: '2021-08-27'

---

Hello everyone!

Today I'm going to be starting a new series of Blog Posts called "Deception in Depth" (a play on Defence in Depth) where my goal is to teach you a little bit about some tricks that I've learned to create your own custom honeypots in your AD Network!

For my first post on Deception -- I wanted to do something special. I have an idea in mind for a work related project right now that I would very much like to pursue, so I'm going to take you through my adventure of how I figured out how to fake user session data in Bloodhound to draw an attacker to my workstation!

## The Attackers Point of View

So lets set the stage -- You're in an enterprise, you've successfully tricked an employee into executing your malware, you recieve a callback to your C2 framework. You dump credentials and you get two sets -- the current user and a new user. After running Bloodhound, you use the pre-built query, "Shortest Paths to Domain Admin" and one pops up. The other user you compromised has a path to domain admin! They actually have a session (and are a local admin) on the device! This must be your lucky day!

Naturally, you want to continue down this attack path. A legit Domain Admin account is always very exciting to compromise. Legit admins do things like this all the time which is why this isn't so out of the ordinary. There isn't much way to detect this is a honeypot until it's too late.

## The Pieces to the Puzzle

Lets get started -- First you'll need to know what's required for this. In an Enterprise, a Security Analyst might not have all these resources avalible to you. Consult with your manager to see if this is something you can possibly get done.

1. Broad deployment of an agent used to inject credentials into LSASS
	- I will hopefully be developing one soon :)
	- This consists of an agent utilizing the CreateProcessWithLogonW Windows API to inject credentials into LSASS. This isn't risky at all. It doesn't involve actually writing any memory yourself into LSASS, so this is a fairly safe method with little risk of devices BSODing 
2. Domain Admin rights within the Domain you wish to deploy this trap
3. at least two domain joined devices (could be Windows Servers or Windows Workstations)
4. Constrained Delegation on at least one of the devices

*Note: Just because I'm showing you how to do this, doesn't mean this is the best way to do this. I am by no means an expert. Just a security researcher with an idea :)*

### My Lab Setup

In my lab, I have the following setup:

The Domain - CONTOSO / contoso.com
Domain Controller - DC / dc.contoso.com
Workstations - WKS01 / wks01.contoso.com* and WKS02 / wks02.contoso.com

Users:
Alice - Admin on wks01
Bob -  Honeyaccount being injected on wks01 which is an admin on wks02
xQc - Domain Admin and Spoofed User Session on wks02


### Setting the Trap

Now that you have an understanding of the setup I have going on, I'm going to walk you step by step through the design and implementation of the trap. First, we're going to start with configuring Constrained Delegation on WKS01. On the Domain Controller, open up Users and Computers and locate you workstation of choice. Like I said before, I will be doing this on WKS02. Once you have located your device, right click and select Properties

![[Pasted image 20210827092425.png]](https://blog.spookysec.net/img/Pasted image 20210827092425.png)
 
You should have the "General" menu pop up, navigate over to the "Delegation" tab.

![[Pasted image 20210827101150.png]](https://blog.spookysec.net/img/Pasted image 20210827101150.png)

Now, select "Trust this computer for delegation to specified services only", and select "Use any authentication protocol". Now click "Add". Another menu should open up called "Add Services".


Now click on "Users and Computers", I'm going to select "WKS02" on the CIFS service.

![[Pasted image 20210827101135.png]](https://blog.spookysec.net/img/Pasted image 20210827101135.png)

Select "Okay", "Apply", then "Okay" once more and you're all done! 

Next up, we'll be heading over to WKS01 with our Admin on that workstation -- Alice. Since Bob is a local admin on this workstation, it should be fairly trivial for us. I elevated privileges to NT AUTHORITY\SYSTEM just by running Print Spoofer really quickly, so I can make calls as WKS01$. I don't know that this is necessary, though.

Now we're going to perform our average Constrained Delegation S4U attack with Rubeus.

 **Step 1** - Ask the DC for a TGT of WKS02 with ``Rubeus.exe tgtdeleg /nowrap``
 
 ![[Pasted image 20210827101920.png]](https://blog.spookysec.net/img/Pasted image 20210827101920.png)
 *Copy the Ticket to your clipboard. We will be using it in just a minute!*
 
 **Step 2** - We now request a TGS for our Domain Admin (xQc) with ``Rubeus.exe s4u /ticket:<ticket> /impersonateuser:xQc /domain:contoso.com /msdsspn:cifs/WKS02 /ptt``
 
![[Pasted image 20210827115200.png]](https://blog.spookysec.net/img/Pasted image 20210827115200.png)

 **Step 3** - Pass the Ticket, this can simply be done with ``Rubeus.exe ptt /ticket:<b64 encoded ticket>``
 
 ![[Pasted image 20210827115242.png]](https://blog.spookysec.net/img/Pasted image 20210827115242.png)
 
 **Step 4** - Verify the ticket is in memory with ``klist``
 
![[Pasted image 20210827115136.png]](https://blog.spookysec.net/img/Pasted image 20210827115136.png)

*Note: if you are running into issues where you cannot access the device in the context of the user you selected, open up a new terminal, export the Kerberos ticket  to the filesystem and inject it into memory on the new terminal session.*

**Step 5** - Attempt to connect to the Targeted Workstation


 As you can see above, the ticket is now cached into memory! Now on WKS01, we're going to run Sharphound (as an attacker theoretically would) and pull the results back to Kali and import the results.
 
 ![[Pasted image 20210827094359.png]](https://blog.spookysec.net/img/Pasted image 20210827094359.png)
 
 Please hold while Bloodhound ingests the data. After it's finished press Control+R, search for our Workstation (WKS01), click on "Sessions" and you should now see there is a session reported on the workstation!
 
 ![[Pasted image 20210827115826.png]](https://blog.spookysec.net/img/Pasted image 20210827115826.png)
 
 This is slightly different from our expectations (of there being a session on wks02, seeing that the constrained delegation attack was targeted at wks02), but we can deal with it! Alls we need to do to correct this is flipflop WKS01 and WKS02 in Active Directory to make it appear the opposite way.
 
Like I said earlier, this is a bit of a different style of blog post. Let me know what you think! Do you want to see more? Let me know on Twitter!
