---
layout: post
title: 2024 CISA ICS CTF - Extend Your Stay
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
Oh boy, we're down to the final few challenges! We're back in the Verbank category with "Extend Your Stay". This time Virbank Medical has detected a suspicious browser add-on installed on a users device; The question is to RE the extension and identify the flag. Let's dive into it!

### Extend Your Stay 1
Okay, so we're given a Chrome Extension (.crx) and we now need to do some analytical work on it. Like most things in live, proprietary file extensions are a fancy archive of sorts. There's an awesome website out there [ezyZip](https://www.ezyzip.com/open-extract-crx-file.html) that allows us to extract the CRX entirely in our browser!

Post-extracting, we're given a handful of files, one in particular stands out - **background.js**. This is likely where the extension source code is saved.

![[Pasted image 20240904095605.png]]("https://blog.spookysec.net/img/Pasted image 20240904095605.png")

A quick overhead view of the file shows an obfuscated function, some code to go through each element and do some replacement work. Towards the end, there's a blob of Base64 that runs a aotb to decode the value and print the flag out.

![[Pasted image 20240904095739.png]]("https://blog.spookysec.net/img/Pasted image 20240904095739.png")

Opening up Chrome's Dev tools, we can paste the code in there and retrieve the flag **flag{hyp3r3xt3nd3d}**!

![[Pasted image 20240904095900.png]]("https://blog.spookysec.net/img/Pasted image 20240904095900.png")

### Extend Your Stay 2
Now, it's stated that some links are being hijacked and are redirecting users to a similar looking URL controlled by attackers. Let's take a look at that obfuscated JavaScript we neglected before.

![[Pasted image 20240904100147.png]]("https://blog.spookysec.net/img/Pasted image 20240904100147.png")

Replacing every ``;`` with a ``;\n`` gives us much more readable code with a couple of Base64 notes. Let's take a quick stab at decoding them and see if we can find anything useful.

![[Pasted image 20240904100421.png]]("https://blog.spookysec.net/img/Pasted image 20240904100421.png")

Well, that certainly looks useful. This time we're given the flag of ``https://www.fellswargo.com/``. Neat! 

### Extend Your Stay 3
Some of the Virbank staff are big bird watchers and they've installed even  more suspicious extensions. This time the new extension is believed to have stolen financial data. Oh lord, when will it end! 

We'll repeat the same process as unpacking the extension as last time and take a peak at background.js.

![[Pasted image 20240904100917.png]]("https://blog.spookysec.net/img/Pasted image 20240904100917.png")

There's some interesting regular expressions in the addon here - One looks about the same length as a card number with 5 as a starting prefix (interesting). Two digits separated by a /, and lastly 3 digits. Some quick Googling shows that **MasterCards** appear to start with 5, so MasterCards are specifically being targeted here, how specific :think: Maybehaps a coordinated attack? 

![[Pasted image 20240904101239.png]]("https://blog.spookysec.net/img/Pasted image 20240904101239.png")

### Extend Your Stay 4
Lastly, Virbank staff want to know where exactly this data is exfiltrated to. A good question! 

I prefer Dynamic analysis in this situation - So I'll fire up Burpsuite, open up the built in Chrome browser and install this add-on. Upon launching it we can see that there is a connection request sent out tooooooo...... ```https://www.b1rds.info```!

![[Pasted image 20240904101833.png]]("https://blog.spookysec.net/img/Pasted image 20240904101833.png")

We've got our domain and can add it to the block-list. 

### Closing Thoughts
Another good challenge here - I don't do much Chrome browser add-on forensics. Not that this is wildly different from analysis of phishing campaigns (in the sense that both focus heavily on obfuscated JavaScript), but it was a nice easy refresher that showcases how powerful both static and dynamic analysis can be at times.

~ Ronnie