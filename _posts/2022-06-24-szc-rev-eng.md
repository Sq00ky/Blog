---

layout: post

title: Source Zero Con CTF - Baby XBee 1-2

gh-badge:

- star

- fork

- follow

tags:

- Capture the Flag

- Reverse Engineering

- Cyber Security

comments: true

published: true

date: '2022-06-24'

---

Hello Everyone!

Welcome to my Source Zero Con CTF Writeup Series. Today we're going to be tackling the Reverse Engineering challenges - RE 1 and RE 2 in the Baby XBee Category.

The two challenges are fairly basic reverse engineering challenges. For this challenge, well be using a tool called "[Binary Ninja](https://binary.ninja/)". Szymex73 introduced me to this tool the other day, and I gotta say, it's one of the better disassemblers that I have worked with. Let's dive into it!

### Baby xBee - RE 1
Download Link: [RE_1.zip](https://drive.google.com/file/d/1O8xSpCU-vWrMBhyd4g7MnnR93nuTW9S1/view?usp=sharing)

To get started, let's launch the program and see what it does.

![[Pasted image 20220624205832.png]](https://blog.spookysec.net/img/Pasted image 20220624205832.png)

Okay - It appears to be a pretty standard "What's the password". Let's open it up in Binary Ninja and take a look at the main function of the binary.

![[Pasted image 20220624210844.png]](https://blog.spookysec.net/img/Pasted image 20220624210844.png)

Now that it's loaded up, we've got the main function. At a high level, we have the banner that we saw during program execution. Notice that we don't have place for user input, but at the bottom of the main function, we can see another function (func09160772) gets invoked. Let's investigate!

### Investigating the User Input Function


![[Pasted image 20220624211901.png]](https://blog.spookysec.net/img/Pasted image 20220624211901.png)

This appears to be the function that checks the key. We can see at the memory address 0040191b is prompting the user to input a key. It appears that Var14 takes user input, so let's update the Variable name to reflect as such. You can do this by double clicking on the variable and typing in your new name.

![[Pasted image 20220624213852.png]](https://blog.spookysec.net/img/Pasted image 20220624213852.png)

Much better! We can now see the if statement at 00401941 a little bit clearer now. The script is comparing the hexadecimal value 0xde06c94c. We can convert this to a string value by right clicking it, selecting "Display As" and selecting "Unsigned Decimal Value". This will give us the decimal value of the string which we can enter into the program.

![[Pasted image 20220624214332.png]](https://blog.spookysec.net/img/Pasted image 20220624214332.png)

Looking back at the function, we can now see that the if statement compares the user input to the value 3724986700.

![[Pasted image 20220624214447.png]](https://blog.spookysec.net/img/Pasted image 20220624214447.png)

### The Solution
Let's try executing the program again and inputting our decimal string:

![[Pasted image 20220624214605.png]](https://blog.spookysec.net/img/Pasted image 20220624214605.png)

And success! We have solved the first challenge.

### Solving with GDB
For fun, let's solve this an alternate way using gdb. To pull this off, we will set a breakpoint before the JNE (Jump if Not Equal to 0) and set this value to 1, so the program will not take the jump. To start, let's take a look at the program in GDB.

![[Pasted image 20220624221958.png]](https://blog.spookysec.net/img/Pasted image 20220624221958.png)

Let's start by disassembling the main function - We can see a large amount of puts that are likely pushing the ascii art bees to the screen. We are interested in the call to func09160722 - This is the call to the function that checks user input. Lets disassemble that function.

![[Pasted image 20220624222304.png]](https://blog.spookysec.net/img/Pasted image 20220624222304.png)

We can see that at the memory address 0x0040193e there is a comparison against the value in the EAX and a local variable on the stack. The local variable is located at RBP-0x8. So, let's set a breakpoint before the JNE is executed.

![[Pasted image 20220624223305.png]](https://blog.spookysec.net/img/Pasted image 20220624223305.png)

We've set our breakpoint with ``break *0x0000000000401941``, now we can ``run`` the program and enter a value into the prompt. If we display the values in the registers, we can see the value we input is in RAX. Specifically in the lower half EAX. Let's dump the memory address that it's comparing EAX against. We can do so with the following command in GDB ``p /u *(int *)($rbp-0x8)``.

![[pic1.png]](https://blog.spookysec.net/img/pic1.png)

We can see that we have decoded the flag, this time in GDB! Let's try setting the Zero Flag in the FLAGS register to 1 so the program does not take the JMP instruction and will invoke the flag decoding function. This can be done in GDB by executing the following command ``set $eflags |= (1 << 6)``

![[solution2.png]](https://blog.spookysec.net/img/solution2.png)

Now that we've had a little bit of fun - let's get started on RE_2

### Baby xBee - RE 2
Download Link: [RE_2.zip](https://drive.google.com/file/d/1OmFxWTRJrannQRVeQTOUMkpKG0CAuMuW/view)

This challenge is arguably easier than the first. When I was first doing this challenge, Szymex loaded up the binary in Binary Ninja, szy had began searching for the main function, while scrolling throughout the program the string "UPX" had caught my eye, making this challenge infinitely easier. The binary had been packed with UPX. We can verify this by grepping the binary for the string "UPX".

![[Pasted image 20220624224401.png]](https://blog.spookysec.net/img/Pasted image 20220624224401.png)

We can see the strings "This file is packed with UPX executable packer" and a link to the UPX website. Nice. Let's unpack this with ``upx -d re_2``. 

![[Pasted image 20220624224443.png]](https://blog.spookysec.net/img/Pasted image 20220624224443.png)

UPX successfully extracted the binary. We can now continue analysis in Binary Ninja. 

![[Pasted image 20220624224628.png]](https://blog.spookysec.net/img/Pasted image 20220624224628.png)

Nice! We can see the intro to the program with some lovely bee ascii art by 0xSN1PE! Shoutout to him for making these awesome challenges. Back to the challenge - Let's grab the hexadecimal strings and load them into CyberChef.

![[Pasted image 20220624225022.png]](https://blog.spookysec.net/img/Pasted image 20220624225022.png)

And it looks like we have the start of a flag, or lag! It needs a bit of fixing...

![[Pasted image 20220624225442.png]](https://blog.spookysec.net/img/Pasted image 20220624225442.png)

Pivoting back over to our trusty friend, the disassembler, we can see that each local variable is being XOR'd with the hey 0xDEADBABE We can fix this in CyberChef relatively easily.
![[Pasted image 20220624225532.png]](https://blog.spookysec.net/img/Pasted image 20220624225532.png)

Notice the F in Flag is still missing :( Maybe the Bees stole it... Anyways, I hope you enjoyed the Writeup on these challenges. Be on the lookout for some more in the coming days. 

Love, Spooks~
