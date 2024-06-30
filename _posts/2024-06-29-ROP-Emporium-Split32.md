---
layout: post
title: ROP Emporium - Split
gh-badge:
  - star
  - fork
  - follow
tags:
  - Linux
  - Cyber
  - Security
  - Exploitation
comments: true
published: true
date: 2024-06-29
---
After a short nap and an Obsidian update, I'm back! This time we're going to tackle Split32. We're going to dive right into this guy and not spend as much time on initial theory unless relevant.

### Initial Program Usage & Static REing
We should always initially use the program like an actual user before we dive into any behavior so we get a solid understanding of how the application actually works.

![[https://blog.spookysec.net/img/Pasted image 20240629201433.png]](https://blog.spookysec.net/img/Pasted image 20240629201433.png)
*Much like ret2win, it simply asks the user for input.*

Great, now that we're totally 100% sure that's all the functionality the program has, we can move onto exploitation, right? Sure, but there may be some other things we want to look at, just like last time in ret2win, there may be some useful functions that we can leverage, so we should take a peak at those first. 

To do this, I'm going to once again open the program up in Ghidra, go function by function and take note of anything interesting.

![[https://blog.spookysec.net/img/Pasted image 20240629201713.png]](https://blog.spookysec.net/img/Pasted image 20240629201713.png)
*Main Function Disassembly*

This time it looks like we have our standard Main function which just prints the standard welcome banner, then invokes the pwnme function. If you're paying close attention, you're probably eyeing that "UsefulFunction" function, which is hopefully, well, useful. Let's check out pwnme. 

![[https://blog.spookysec.net/img/Pasted image 20240629201904.png]](https://blog.spookysec.net/img/Pasted image 20240629201904.png)
*PwnMe Function Disassembly*

Just like last time, we can see it takes in 40 bytes of data and tries to shove it in a buffer that can handle a max of 96 bytes of data. This is an overall improvement from last time. Before we could only fit 56. We should be able to get more creative this time around if needed. Let's take a peak at the UsefulFunction next.

![[https://blog.spookysec.net/img/Pasted image 20240629202256.png]](https://blog.spookysec.net/img/Pasted image 20240629202256.png)
*UsefulFunction Function Disassembly*

Wow, that *is* indeed a useful function, it's no ``/bin/bash`` or ``/bin/cat flag.txt``, but I'm sure we can work with it. Next up, let's check out the available strings that are in the binary that we can work with. We can do this in Ghidra by going to Search -> For Strings -> Search All.

![[https://blog.spookysec.net/img/Pasted image 20240629202441.png]](https://blog.spookysec.net/img/Pasted image 20240629202441.png)
*Output of Strings stored within the Binary*

Interesting - there's a /bin/cat flag.txt stored in the binary, though it's not stored within any of the functions. Fortunately for us, we don't need it to be for it to be usable - we just need it to be present or else we'd have to do some 1337 h4x0r magic. Let's check the security features of the binary this time around and see if ASLR or any other security technologies are enabled that may throw a wrench in our plans.

![[https://blog.spookysec.net/img/Pasted image 20240629202821.png]](https://blog.spookysec.net/img/Pasted image 20240629202821.png)
*Output of Checksec* 

This time it only appears that the NX-bit is set, so this means that DEP (Data Execution Prevention) is in use. This means for us that *data stored on the stack is non-executable*. In order to bypass this we need to use a technique called Return Oriented Programming, or ROP for short. 

### Overflowing the Buffer & Controlling the EIP

This will be our first introduction to using very short ROP-gadgets. It starts off simple but gets complicated very quickly if you're not fluent in Assembly. I'm not fluent by any means and I've taken **multiple** course on reversing, malware analysis and binary exploitation.

Okay - so now that we're aware of the security features we can start prototyping out exploit. We already know there's a 40-byte buffer that we need to overflow. We can keep the same initial formula we setup in ret2win and see if it works.

![[https://blog.spookysec.net/img/Pasted image 20240629203312.png]](https://blog.spookysec.net/img/Pasted image 20240629203312.png)
*Output of ``python -c 'import sys;sys.stdout.buffer.write(b"A" * 44 + b"1337")' | ./split32 && dmesg | grep split32``*

Awesome, it did *and* we already have control of the EIP. Let's see if we can call UsefulFunction and get the outputs. We can do this by modifying out payload with the starting address of the function (\x08\x04\x86\x0c).

![[https://blog.spookysec.net/img/Pasted image 20240629203932.png]](https://blog.spookysec.net/img/Pasted image 20240629203932.png)
*Re-running our POC getting the contents of the current directory listed out to us*

So far so good, modifying the EIP to contain the start address of our function allowed us to run /bin/ls.

### One Rop, Two Rop, Red Rop, Blue Rop
Running /bin/ls is great and all, but how exactly can we weaponize this? Rop. It's always the answer. Probably. At least it is here. I honestly wouldn't even count this as baby's first ROP chain, but you know. If it works, it works.

Essentially, our goal is going to be to call System, then place the address of /bin/cat flag.txt in the place of /bin/ls. So what exactly do we need to do? Replace our 1337 placeholder with the address of System (\x08\x04\x86\x1a), then place our /bin/cat flag.txt address (\x08\x04\xa0\x30) afterwards. This will give us a payload that looks something like so:

```
python -c 'import sys;sys.stdout.buffer.write(b"A" * 44 + b"\x1a\x86\x04\x08"+b"\x30\xa0\x04\x08")' | ./split32
```

![[https://blog.spookysec.net/img/Pasted image 20240629210257.png]](https://blog.spookysec.net/img/Pasted image 20240629210257.png)
*Success - We've retrieved the flag!*

Okay, so can we do the same exact thing if we print out the memory address of libc's System call? Sure, given the extra buffer space, we definitely can. Let's give it a try.

Some preliminary info that you might need to know beforehand - the System function call requires a 4-byte Return address, so we'll need to supply it garbage. Or, we could supply "exit", so we can gracefully exit the program.

Let's start by using GDB to grab the address of system. We can find this with print $functionName

![[https://blog.spookysec.net/img/Pasted image 20240629211116.png]](https://blog.spookysec.net/img/Pasted image 20240629211116.png)
*Output of print system*

Great, now that we've got our address of system, we'll just need to substitute it out.

```
python -c 'import sys;sys.stdout.buffer.write(b"A" * 44 + b"\xe0\x83\x04\x08"+b"GARB"+b"\x30\xa0\x04\x08")' | ./split32
```

Alternatively, as I said before, we can supply the exit function address. We can grab this by the same method we used before to get systems.

![[https://blog.spookysec.net/img/Pasted image 20240629211827.png]](https://blog.spookysec.net/img/Pasted image 20240629211827.png)
*Output of break main and print exit*

The address is \xf7\xc3\xd2\x20. We can replace our placeholder GARB with this and run our exploit and see if we gracefully exit after getting the flag:

```
python -c 'import sys;sys.stdout.buffer.write(b"A" * 44 + b"\xe0\x83\x04\x08"+b"\x20\xd2\xc3\xf7"+b"\x30\xa0\x04\x08")' | ./split32
```

Now, we'll run the proof of concept and...

![[https://blog.spookysec.net/img/Pasted image 20240629211956.png]](https://blog.spookysec.net/img/Pasted image 20240629211956.png)

Success - we've retrieved the output of flag.txt without triggering a segfault. This really brings us to the end of Split32. As we move deeper and deeper into the ROP Emporium series, hopefully we'll start working towards popping a full blown shell. 
