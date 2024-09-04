---
layout: post
title: 2024 CISA ICS CTF - Follow the Charts
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
Another challenge from Virbank city - this time Virbank employees have been spotted installing unauthorized software. An FTP server was recently setup on one of the hospital's servers (yikes) and has been used for hosting video games and such! They identified an interesting executable of interest that is stored in **malcolm**.  Our task is to find it and retrieve the hash.

This CTF has some infrastructure setup for the players to use; [Malcolm](https://github.com/cisagov/Malcolm), [Arkime](https://arkime.com/), [NetBox](https://github.com/netbox-community/netbox) and [CyberChef](https://github.com/gchq/CyberChef). Some of these services we'll be using in this challenge, some won't. I'll probably put this brief little introduction in each post so we're all on the same page. This challenge, we definitely need to use Malcolm!

### Follow the Charts - 1
Our first step is to search for any FTP Data in Malcolm. As it turns out, it's the first entry in the list. Neat!

![[Pasted image 20240903231924.png]](https://blog.spookysec.net/img/Pasted image 20240903231924.png)

Clicking on it will download a .zip file, this **must** be opened in 7-zip as the file is stored in a hidden . file that Windows just hates for some reason. Inside, there is a Linux binary executable. Using WSL, we can quickly grab the file hash - **24c63120e35bf29b47403df5378679fa**.

![[Pasted image 20240903232051.png]](https://blog.spookysec.net/img/Pasted image 20240903232051.png)

### Follow the Charts - 2
Next up, Virbank IT staff determined employees were using the executable, they would like us to identify where it was pulling updates from. I think the easiest method here is to use *ltrace* or *strace* here to see what the applications executing on the system. Using *ltrace* on the application, we can see it's calling wget to download a file from Dropbox. 

![[Pasted image 20240903232258.png]](https://blog.spookysec.net/img/Pasted image 20240903232258.png)

Opening up the file gives us a nice flag **flag{H1t_m3_w17H_y0Ur_b3S7_5Ho7}** and some goodies by Jack Black.

![[Pasted image 20240903232339.png]](https://blog.spookysec.net/img/Pasted image 20240903232339.png)

### Follow the Charts - 3
Virbank IT staff believe that this update deployed a RAT and established C2. I really hope it didn't because I ran this on my host WSL instance :D Jokes aside - If we continue our execution flow with *ltrace*, we're actually presented with the flag - **flag{W31C0Me_t0_tH3_JUn6L3}**.

![[Pasted image 20240903232635.png]](https://blog.spookysec.net/img/Pasted image 20240903232635.png)

Though, this wouldn't be echo'd to the screen - just piped into the update.log file then removed. If you wanted to do this the normal way, we could open the binary up in GDB and do some breakpoint magic! Let's take a peak.

Over on my Kali VM, I spun up GDB and dumped the functions with the ``info functions`` command:

![[Pasted image 20240903233000.png]](https://blog.spookysec.net/img/Pasted image 20240903233000.png)

There's an interesting function here named execbash, let's disassemble it and see what's inside. We can use the ``disassemble execbash`` command to do so:

![[Pasted image 20240903233106.png]](https://blog.spookysec.net/img/Pasted image 20240903233106.png)

Interesting - this looks like our function. Let's set a break point on Main and then pause right before the call to remove. We can do this with ``break main``, resuming the execution flow with ``c`` and then once our breakpoint is hit, ``break remove@plt``. Alternatively, we could have done \*0xD34DB33F (or whatever the memory address would be).

![[Pasted image 20240903233559.png]](https://blog.spookysec.net/img/Pasted image 20240903233559.png)
Opening up another Terminal, browsing to our directory location shows us the Update.log file exists, catting it reveals our flag :D

![[Pasted image 20240903233644.png]](https://blog.spookysec.net/img/Pasted image 20240903233644.png)
So there's two different ways you could have tackled this guy. One more technical, one less technical.
### Follow the Charts - 4
Lastly, Follow the Charts 4. Auuhhhhhh. Truth be told, I didn't actually solve this one. Though, the challenge itself is particularly interesting. Virbank IT staff believes that it may be possible to hijack the execution flow with a custom Chart to remove the malware. This involves Reverse Engineering the magic they did to to make the charts, which is incredibly rough. Alls CISA & Co want you to do with this one is invoke ``echo hello`` and the site will print you out the flag.

As I said before, I didn't actually solve this one; though I am technically capable of solving it, and I think it's a really neat challenge. I just don't have the time or energy to. So, let's talk about how we **can** solve it. First step would be throwing GDB out the window (for now) and loading the binary into a real disassembler like Ghidra. As seen before in GDB, there are several interesting functions. Namely five2bytes, createnote, connect, chart2notes, appendnote, note2five and secretFunction.

![[Pasted image 20240903234304.png]](https://blog.spookysec.net/img/Pasted image 20240903234304.png)

Wow, that's a lot of interesting functions.  Let's take a look at SecretFunction first. It's just:

```
  printf("Im a silly little guy and sometimes forget what the note struct looks like.
  Here it is: %s",
         "typedef struct note{
	         bool green;
	         bool red;
	         bool yellow;
	         bool blue;
	         bool orange;
	         struct note* next;
		} note_t;
         ");
  return;
```

Oh boy - struct type definitions!!! My favorite. Looking at the createnote function, this is actually where the struct lives, so you could populate its definitions and all that fun stuff. It'll look something like this:
![[Pasted image 20240904001104.png]](https://blog.spookysec.net/img/Pasted image 20240904001104.png)

Now, it's time to pivot over into some of the other functions, namely the big scary ones like chart2note, decodechart, etc. You cannot just toss random numbers in there and brute force this little guy. It's what makes it kind of hard, you have to clearly understand the data format here and how it's being transformed to ultimately get the flag and change the execution flow. Dynamic analysis might be easier than static here, but unfortunately I got started 2 days late. 

### Closing Thoughts
I really liked this challenge - it was the right amount of forensics, reverse engineering and exploitation in it. I really wish I had a few more days to look deeper into 4. I think it's a really neat challenge, and I'll definitely be looking forward to reading writeups on how the rest of it goes (if available). There's a few more writeups I'd like to finish before the CTF ends.

~ Ronnie
