---
layout: post
title: ROP Emporium - Ret2Win 
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
date: 2024-06-28
---

Wow, it's been a long while since I've written one of these things. Just over 7 months to be exact, going forward into '24, I should really be better about that.

Anyways, I'm traveling this weekend and just finished up SANS SEC660/GXPN (I passed btw!). One of my major weakpoints in offensive ops is Binary Exploitation - I really truly suck at it and this is kinda my last ditch effort to try to be good at it. After failing OSED last year, I kinda went into crisis mode and had a moment of clarity.

```
It's okay that I failed OSED - Not everyone can be good at everything. I might just not be good at Binary exploitation and I'm okay with that. - Ronnie, 12/3/2021
```

However, I'm a stubborn one and wasn't ready to give up quite yet. Doing SEC660 was going to be my last hope at getting gud, and in the process of getting gud, one has to practice, though practicing doesn't make for perfect. Practicing and succeeding makes perfect. There's a wonderful quote that one of my professors said once:

```
Practice doesn't make perfect. Perfect practice makes perfect. - C.H., Cisco 1
```

To this day, I *still* can't terminate a CAT cable and that's okay because I didn't end up majoring in networking, but you know what I can do? Basic binary exploitation! In this new blog post series we're going to practice binary exploitation by making our way through the [ROP Emporium challenges](https://ropemporium.com/). 

### How BinEx
I'll put this disclaimer out there, I'm not an expert and don't claim to be, just like the rest of everyone, an eternal student at life, so I'm going to do my best job at trying to explain things along the way. First things first, what is Binary Exploitation and how do we do it? 

Binary Exploitation is a general term that *most often* refers to some sort of buffer overflow vulnerability within an application. This application could be simple or complex - network based, gui, or command line based, but could be much broader, like exploiting a custom SUID binary by performing command injection or something. For the sake of what we're doing, Binary Exploitation will encompas all sorts of buffer overflowz. 

Now that we've set a common understanding of what BinEx is (to me \[at least\] and us), we can move onto the How. How Binex. I don't really have a good comparison on hand, so let's just wing it, Let's say you've got a jug that you keep your loose change in. You cut the cap so it can only fit small denominations of change like the penny. After filling it up a couple of times, you've determined that it is completely full at exactly 203 pennys which is equal to $2.03. Makes sense, right?

Well, your friend comes over the next day and has a *dime*. For the non-americans, Dimes are worth 10 pennys and are a physically smaller coin. Your friend sees that you're collecting change and adds their spare dimes to your cash jug. Eventually you fill up the jug, but you notice something. It's over your expected $2.03. How did this happen? The jug explodes everywhere, scattering all your coins across the room. The only thing left in it's wake are 2 dimes your friend added.

*That in a nutshell is a really poor description of a buffer overflow*. You take a large amount of data and put it in a small buffer size and hope to trigger a crash within the application. Okay! Now that the poor anology is out of the way, your friend overnight became a master magician and does the *same exact thing*, except this time, he adds a **very specific** amount of change to your jug, while you keep contributing the normal amount. Eventually the jug fills up and somehow, all the money you saved magically floats over to your friends house and into his pocket instead. How in the world did that happen?!

Well, in Binary Exploitation, if we are lucky, we can overwrite certain values in CPU registers to hijack the execution flow of the program. Sometimes this is easier than others, it really depends on what security mitigations are put in place. For example, your friend may hide the location of the jar, or may reinforce the jug and put multiple layers around it to catch all the coins if it breaks. This is a really bad analogy for ASLR and SEH overflows. 

Anyways - we're going to do this with the ROP Emproium labs - we'll be using performing buffer overflows in the programs that they've created and hijack the execution flow of the program to do our own bidding. Neat stuff. 

### Lab Setup
For ROP Emproium, I'll be using 6-ish tools:
- Linux ([Kali](https://www.kali.org/) for me - this is not necessary, any Linux distribution will work)
- [Pattern_Create.rb](https://github.com/rapid7/metasploit-framework/blob/master/tools/exploit/pattern_create.rb) & [Pattern_Offset.rb](https://github.com/rapid7/metasploit-framework/blob/master/tools/exploit/pattern_offset.rb) from Metasploit
- Python
- GDB
- [GDB-PEDA](https://github.com/longld/peda) (a Exploit Development extension for GDB)
- [checksec.sh](https://github.com/slimm609/checksec.sh)

In addition, we'll be using the 32-bit non ARM/MIPS binaries for this challenge.

That's pretty much it for the administrative tasks - I won't go into details on VM setup, GDB Peda, checksec or any of that stuff. I have faith in you!

### Finding the EIP Offset
The very first task we have is to overflow the buffer. First, let's run the program and get used to the input and output excepted by the program:

![[https://blog.spookysec.net/img/Pasted image 20240629001347.png]](https://blog.spookysec.net/img/Pasted image 20240629001347.png)

Fairly straight forward - running the program prompts us for input. We can try a simple overflow by having Python print a ton of A's for us.

![[https://blog.spookysec.net/img/Pasted image 20240629001518.png]](https://blog.spookysec.net/img/Pasted image 20240629001518.png)
``python -c 'import sys;sys.stdout.buffer.write(b"A" * 400)' | ./ret2win32``

Okay, neat! Segfaults are an indicator that the program crashed, let's look at dmesg for more info:

```
kali@kali$ dmesg | grep ret2win
[ 1370.915721] ret2win32[13617]: segfault at 41414141 ip 0000000041414141 sp 00000000ffd9b4e0 error 14 in libc.so.6[f7c00000+22000] likely on CPU 1 (core 1, socket 0)
```

It appears that we've overwritten the IP (Instruction Pointer) with all As (\x41\x41\x41\x41). This brings us to our first teachable moment. *What is the Instruction Pointer*. The Instruction Pointer is a CPU Register that handles the execution flow of the program. This means that whatever we write into that CPU Register will get executed - if we can control this register, we can control the execution flow of the program. On 32-bit systems, we have the EIP and on 64-bit we have the RIP.

Its great that we have control of the instruction pointer because as said before, it allows us to control the execution flow and that's great and all, but we need to have specific control of the instruction pointer to control the execution flow. How exactly can we do that? Fortunately for us, it's actually pretty simple. We can use a cyclical pattern that doesn't repeat to figure out the exact value that the EIP will store. The observant among you may have noticed the tool we're going to use - Pattern_Create && Patern_Offset. 

![[https://blog.spookysec.net/img/Pasted image 20240629082230.png]](https://blog.spookysec.net/img/Pasted image 20240629082230.png)

The program itself is relatively straight forward - you just need to supply it a length value and it'll generate a pattern for us. After generated, we can supply it to ret2win32 and we can observe our crash.

![[https://blog.spookysec.net/img/Pasted image 20240629082448.png]](https://blog.spookysec.net/img/Pasted image 20240629082448.png)

We'll check dmesg one last time and see that the value \x35\x62\x41\x34 made it into the EIP which converts to 5bA4. Wait, 5bA4? That wasn't in our pattern? At Offset 44 of the string we have 4Ab5. This has gotta be some sort of mistake, right? 

<img src='https://media1.tenor.com/m/eRD89_uiAvsAAAAC/nerd-well-actually.gif'> 

No, it's not. There's this fun thing called "Endianness" which changes how data is stored. On x86, Little Endian is used, so when we want to specifically place a value in the EIP, we need to account for the way how data is stored in memory. 

### Controlling the Instruction Pointer
As an example of demonstrating how Little Endian works, let's try to write 1337 into the EIP - Our initial thought is we need to write in \x31 \x33\x33\x37, let's try that and see how it looks. This time we're going to load up GDB. We know that we must write at least 44 bytes of garbage into memory before we can gain control of the EIP, then we'll need to write our \x31\x33\x33\x37 string. So our command will look something like this:

```
python -c 'import sys;sys.stdout.buffer.write(b"A" * 44 + b"\x31\x33\x33\x37")'
```

In GDB, the syntax to run a command while in the debugger is something like so:

```
run < <(python -c 'import sys;sys.stdout.buffer.write(b"A" * 44 + b"\x31\x33\x33\x37")')
```

![[https://blog.spookysec.net/img/Pasted image 20240629094039.png]](https://blog.spookysec.net/img/Pasted image 20240629094039.png)

It looks like we have control over the EIP and the value 1337 made it in, though it's in Big Endian format right now, not Little Endian. We know this because it's the same string but reversed. Let's try DEAD this time:
![[https://blog.spookysec.net/img/Pasted image 20240629094258.png]](https://blog.spookysec.net/img/Pasted image 20240629094258.png)
Again, we can see the order is reversed. D->A->E->D, so we'll want to keep this in mind anytime we want to inject a specific value into memory. Fortunately for us, [CyberChef has a Swap Endianness recipe that we can use!](https://gchq.github.io/CyberChef/#recipe=Swap_endianness('Hex',4,true)From_Hex('Auto')&input=MHgzNzMzMzMzMQ)

![[https://blog.spookysec.net/img/Pasted image 20240629094521.png]](https://blog.spookysec.net/img/Pasted image 20240629094521.png)

### Redirecting the Execution Flow
Believe it or not, we're closer to the end than you might think - we need to find out what exactly it is that we want to do with our control. Well, let's take a look at the program in Ghidra. There's a couple ways we could theoretically solve it:
- Ret2Libc
- Custom Shellcoding
- Ret2Function

We can see there's two main functions being called Main && PwnMe. Though, there's another function called Ret2Win, we'll take a look at that in a moment.

![[https://blog.spookysec.net/img/Pasted image 20240629100204.png]](https://blog.spookysec.net/img/Pasted image 20240629100204.png)
*Main Function Disassembled*

![[https://blog.spookysec.net/img/Pasted image 20240629100257.png]](https://blog.spookysec.net/img/Pasted image 20240629100257.png)
*PwnMe function decompiled*

We can see that our buffer size is actually 40 bytes of space, despite needing 44 to control the value in the EIP. 

![[https://blog.spookysec.net/img/Pasted image 20240629101037.png]](https://blog.spookysec.net/img/Pasted image 20240629101037.png)
*Ret2Win function decompiled*

Well, a /bin/cat flag.txt certainly seems promising. So, using control of the instruction pointer, how can we call this function? Well, because it doesn't take any arguments it's actually super easy *assuming ASLR is disabled*, we just need to supply the memory address of ret2win in Little Endian format.

Looping back over to GDB - we can call ``print functionnamehere`` to retrieve the addess:

![[https://blog.spookysec.net/img/Pasted image 20240629101256.png]](https://blog.spookysec.net/img/Pasted image 20240629101256.png)
*Printing the Ret2Win function address and function disassembly*

Alls we need to do is replace our \x31\x33\x33\x37 with is the address of 0x0804862c and we *should* have the output of the flag file. Let's give it a try.

```
run < <(python -c 'import sys;sys.stdout.buffer.write(b"A" * 44 + b"\x2c\x86\x04\x08")')
```

![[https://blog.spookysec.net/img/Pasted image 20240629101918.png]](https://blog.spookysec.net/img/Pasted image 20240629101918.png)

We can see that our command executed successfully! Great!  Let's make sure we can run this outside of the debugger.

```
python -c 'import sys;sys.stdout.buffer.write(b"A" * 44 + b"\x2c\x86\x04\x08")' | ./ret2win32
```

![[https://blog.spookysec.net/img/Pasted image 20240629185114.png]](https://blog.spookysec.net/img/Pasted image 20240629185114.png)

Success! We still get a segfault, though which sucks. Let's add a quick call to the exit() function just to make sure everything is nice and clean:

![[https://blog.spookysec.net/img/Pasted image 20240629185244.png]](https://blog.spookysec.net/img/Pasted image 20240629185244.png)
*GDB Output of print exit, then adding the memory address of exit to our python one-liner.*

Much better! To be honest, I had much more grand plans for this post, like making it an SUID binary and spawning a shell, but those kind of fell through with the specific language of "I will attempt to fit 56 bytes of user input into a 32-bytes of stack buffer", which we can see if we actually read the function. This is why Reverse Engineering is important, same w/ Shellcode size - it's very easy to exceed the buffer size limitations and that matters. It can completely break your plans.

![[https://blog.spookysec.net/img/Pasted image 20240629185543.png]](https://blog.spookysec.net/img/Pasted image 20240629185543.png)

Anyways, I even learned something out of this one. In the next post we'll move onto Split
