---
layout: post
title: 2024 CISA ICS CTF - Register the Dots
gh-badge:
  - star
  - fork
  - follow
tags:
  - CTF
  - CISA
comments: true
published: true
date: 2024-09-03
---
We're onto the next competition category in the CISA ICS CTF - This time we're taking a look at a challenge in Driftveil City; Register the Dots. This CTF has some infrastructure setup for the players to use; [Malcolm](https://github.com/cisagov/Malcolm), [Arkime](https://arkime.com/), [NetBox](https://github.com/netbox-community/netbox) and [CyberChef](https://github.com/gchq/CyberChef). We probably won't be using any of these services, but I'm putting this disclaimer in there just in case so we're all on the same page if you see me use any of the tools.

![[Pasted image 20240903211847.png]]("https://blog.spookysec.net/img/Pasted image 20240903211847.png")

### Registering the Dots 1, 2a, 2b
The challenge starts off with a quick story about an IT worker in Driftveil city named Benji. During an audit, Benji noticed weird network activity originating from her workstation and ran KAPE. Our task is to analyze the results to see if we can identify the weird process that's causing this network traffic.

Our first step is to extract the zip file. I like to use Sublime's File Tree explorer, on initial discovery, I noticed a few interesting things - in the Recycle Bin there's dns.sh, that in itself is interesting, though on startup, we should look for scheduled tasks & services.

![[Pasted image 20240903212508.png]]("https://blog.spookysec.net/img/Pasted image 20240903212508.png")
So, down to C:\\Windows\\System32\\Tasks.... and there's a couple. Starting at the top, we have FileZilla Auto Connect Server. Wouldn't you know? It looks suspicious as all hell, lol.

![[Pasted image 20240903212936.png]]("https://blog.spookysec.net/img/Pasted image 20240903212936.png")

Executing a file in C:\\Users\\Benji\\AppData\\Local\\Temp\\**ditto.exe**, totally not suspicious. Uploading this file to Tria.ge (Recorded Future's Malware Sandbox), we see totally legit FileZilla activity.

![[Pasted image 20240903220106.png]]("https://blog.spookysec.net/img/Pasted image 20240903220106.png")

Though notice it's calling %appdata%\\FileZilla\\SiteManager.xml - taking a peak in that directory, there is no sitemanager.xml file. Looking in Roaming however, there is a FileZilla folder that contains sitemanager.xml with some interesting settings:

![[Pasted image 20240903220352.png]]("https://blog.spookysec.net/img/Pasted image 20240903220352.png")

An IP Address (**165[.]227[.]251[.]182**), Port, User, Base64 encoded password and more. A simple CyberChef recipe shows the password is **easy2W3ar**. 

![[Pasted image 20240903220444.png]]("https://blog.spookysec.net/img/Pasted image 20240903220444.png")

### Closing Thoughts
Overall, this was another super grounded challenge set - going into this, I wasn't really sure what KAPE was, how it worked, or anything like that, so I'm glad I did this challenge. Fairly straight forward, though there was a few red herrings that threw me, like the files in the Recycle bin.

~ Ronnie