---
layout: post
title: 2024 CISA ICS CTF - Read Askew Manuscripts
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
I'd like to think this forensics challenge is word play for RAM (Random Access Memory && Read Askew Manuscripts), with a little bit of hinting at future challenges to come. This was a great one, so buckle up and let's get on into it. After this last challenge set in Virbank, it's Potpourri.

### Read Askew Manuscripts 1
Virbank Medical has recieved a call from Driftveil Police with news. Patient data x-ray data was stolen. Our task is to identify who dunnit! First of all, we need to identify the Serial Number of the X-Ray machine to verify our memory dump looks all good. We're given the hint that the Registry Hive is stored in Software\\ACME_XRay.

Okay! To do this challenge, we're going to need Volatility 3. This is an awesome forensics tool for analyzing memory dumps. I have to re-learn this tool pretty much every year because of how cool and useful it is. I love CTFs with these types of challenges, they're my absolute favorite. Since we know the key, we can run ``vol.py -f ./memdump.raw printkey --key 'SOFTWARE\ACME_XRAY'`` to dump the key, giving us the flag **flag{f33l1ng_v0l@t1l3}** - if we might consider running HiveList, HiveScan and other registry related utilities in Volatility to get a better lay of the system.

![[Pasted image 20240904103253.png]]("https://blog.spookysec.net/img/Pasted image 20240904103253.png)

### Read Askew Manuscripts 2
Next, we're informed the thief tried to upload the stolen patient data to the cloud :( However, the X-Ray machine was not allowed to access the internet. We're tasked with trying to identify the password they used to try to login to the site with. To do so, we're going to want to list the running processes. We can do this with ``vol.py -f ./memdump.raw windows.pslist.PsList``. This time we can see a couple of interesting processes running. Notepad.exe and IEXPLORE.exe

![[Pasted image 20240904103518.png]](https://blog.spookysec.net/img/Pasted image 20240904103518.png)

Internet Explorer sounds like a good candidate! Let's dump the processes memory with ``vol.py -f ./memdump.raw windows.memmap.Memmap --pid 1568 --dump``. This will dump **all** of the process memory.

![[Pasted image 20240904104303.png]](https://blog.spookysec.net/img/Pasted image 20240904104303.png)

Now we can run something like ``strings`` against it with a grep clause for ``http`` or ``https``. This reveals an interesting hit! ``Administrator@https://www.ev1lf1lestorage.info/?directory=images&user=ominousnoteperson&passB64=aWxpa2V3cml0aW5nb21pbm91c25vdGVz&login=true``. It even includes a Base64 encoded password! 

![[Pasted image 20240904104425.png]](https://blog.spookysec.net/img/Pasted image 20240904104425.png)
Decoding it gives us a flag - **ilikewritingominousnotes**.

![[Pasted image 20240904104509.png]](https://blog.spookysec.net/img/Pasted image 20240904104509.png)
### Read Askew Manuscripts 3
Now, the Virbank IT Team needs assistance in identifying who's patient data was stolen. Oh boy. Truth be told, this one took me quite a while, My approach here was to continue to comb through all the strings-esq data stored in the process and eventually found a few interesting hits:

![[Pasted image 20240904105021.png]](https://blog.spookysec.net/img/Pasted image 20240904105021.png)

Some HTTP connection requests to ``172.22.195.22:8000``; with ``strings ./pid.1568.dmp |  grep -i http -A 20 -B 20``, I accidentally found the answer, lol. Or at least one possible answer. My first guess was actually Stephen_Laird, because I thought Phoenix_Wright was there as a joke, *well* as it turns out, Stephen Laird is actually a medical doctor. So, yeah, I guessed wrong. It's **Phoenix Wright**. His X-Ray data was stolen!

### Read Askew Manuscripts 4
Now Virbank IT Staff want to ensure we can recover the X-Ray. The nightmare just doesn't end!!! Okay, it's honestly not that bad. We just need to use FileScan to search for Phoenix_Wright.png - this can be done with ``vol.py -f .memdump.raw windows.filescan.FileScan | grep Phoenix``. Now, we need to dump that portion of the process! This can be done with DumpFiles. ``vol.py -f ./memdump.raw windows.dumpfiles.DumpFiles --physaddr 0x978c820``.  If successful, it should be written as a .dat file to disk.

![[Pasted image 20240904105805.png]](https://blog.spookysec.net/img/Pasted image 20240904105805.png)

Renaming our .dat file to Phoenix_Wright.png, we should be able to now open it in our photo viewing software of choice! It's Paint 3D for me!

![[Pasted image 20240904105908.png]](https://blog.spookysec.net/img/Pasted image 20240904105908.png)

This gives us yet another flag - **flag{0bj3ct10n\_$t0p\_l00k1ng\_@\_my\_b0n3s}**. 
### Read Askew Manuscripts 5
We're almost there, I promise! The last question: 

```
It seems the thief was working for, or being extorted by, somebody else. This unknown actor must have left instructions for returning the flash drive to them, but the only clue found at the scene was a smudged sticky note with two readable words: `trips` and `huffs`. A colleague asked if you had found all three words; you responded, `What 3 words`.  
  
Law enforcement hopes to catch the extorter at the drop site but it's a long drive, and every long drive needs a soundtrack. If investigators needed a song specifically about the contents of the structure at this location, what is the birth city of the artist whose discography they should consult?
```

There's key words referenced in here, I pretty much had to copy and paste it so I didn't mistype anything. So - this is an interesting one and learned something cool out of this. What3Words. What3Words is a means to share a location based out of words. It's a [Website](https://what3words.com/); a hella cool one at that. So, we've got 2 out of 3 words. Where in the world might the third be?

Welllllllll, there was an instructions.txt referenced, so that's definitely a lead. Also, there was Notepad running. Let's take a peak at the command line arguments and see if Notepad has it open. We can do this with ``vol.py -f ./mem.raw windows.cmdline.CmdLine``.

![[Pasted image 20240904110542.png]](https://blog.spookysec.net/img/Pasted image 20240904110542.png)

Okay, cool! I'm sure the intended solution here is to dump the process memory, however, that's lame. Let's open the entire mem dump in HxD and search for ``trips`` and ``huffs``.

![[Pasted image 20240904111403.png]](https://blog.spookysec.net/img/Pasted image 20240904111403.png)

Ta-da! We did it! Probably the unintended way, but that's what happens when you try to dump text files out of memory. It doesn't work as well. But what totally does is searching for the precise string we need :D

Okay, okay, let's get the solve. W3W gives us the location of The World's Largest Ball of Twine. Yeah... That tracks...

![[Pasted image 20240904111559.png]](https://blog.spookysec.net/img/Pasted image 20240904111559.png)
The question specifically wants to know that if the investigators needed a song about the contents of the structures location, what artist should they consult?

As it turns out, the answer is Weird Al. It turns out he's from **Downey**, California.

![[Pasted image 20240904111701.png]](https://blog.spookysec.net/img/Pasted image 20240904111701.png)

Man, what a pivot, lol. So that's it. Quite the story of twists and turns, ultimately leading us to the answer of "We're on our way to the biggest ball of twine!".

### Closing Thoughts
I'm a sucker for forensics challenges like these - they're straight forward and simple to solve. This one had some nice story behind it, and I was constantly on my toes trying to figure out which Volatility3 command would give me the things I needed. Overall, my favorite challenge next to Mission Inconceivable. Potpourri challenges are up next!

~ Ronnie

