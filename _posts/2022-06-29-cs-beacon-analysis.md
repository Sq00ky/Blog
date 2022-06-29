---

layout: post

title: Cobalt Strike Beacon Analysis from a Live C2

gh-badge:

- star

- fork

- follow

tags:

- Malware Analysis

- APTs

- Cyber Threat Intel


comments: true

published: true

date: '2022-06-29'

---
Hello Everyone!

Welcome back to a new type of post, this one is going to be a litte bit different from my normal blog posts. Today we're going to talk about a real live piece of malware that has been attributed to TA578 and IcedID/Bokbot.

At the time of writing, I was able to locate a real live Cobalt Strike sample thanks to Brad over at [@Malware_traffic](https://twitter.com/malware_traffic). If you're unfamiliar with him and his work, he works for Palo Alto Unit 42 and provides PCAP samples of malware running in his lab. It's a remarkable thing to do, and I hope others follow suit in the future. 

Today, me and my coworker were doing some analysis of this [specific malware samples PCAP](https://www.malware-traffic-analysis.net/2022/06/27/index.html) that was posted and something interesting caught our eyes. We were able to identify that an adversary used Powershell to download another stage that had lead to Cobalt Strike. Here's the specific URL the Adversary hit:

```hxxps[://]solvesalesoft[.]com:8080/coin``` 

I have also saved this URL on Archive.org. Click [here](https://web.archive.org/web/20220629190838/https://solvesalesoft.com:8080/coin) at your own risk.

I fired up my Kali VM and went to the URL mentioned above, and to my suprise - The URL was still live. Wow - We have a living C2 Server!

![[Pasted image 20220629180324.png]](https://blog.spookysec.net/img/Pasted image 20220629180324.png)

We have ourselves a nice giant base64 encoded glob here, let's scroll all the way down to the bottom of the file and see what else may be lurking below.

![[Pasted image 20220629180435.png]](https://blog.spookysec.net/img/Pasted image 20220629180435.png)

### Decoding Base64 + GZIP

Interesting - So we have a Base64 encoded GZIP stream that needs to be decompressed. So far, this is pretty standard for Cobalt Strike. Let's copy the base64 into CyberChef and decode it. The Decoding recipe can be found [here](https://gchq.github.io/CyberChef/#recipe=From_Base64('A-Za-z0-9%2B/%3D',true,false)Gunzip()).

![[Pasted image 20220629180631.png]](https://blog.spookysec.net/img/Pasted image 20220629180631.png)

The PowerShell script certainly didn't lie... Here's our deobfuscated PowerShell script! I'll be honest, I'm going to skip *a lot* of this. This is all pretty standard way to run EXEs from PowerShell. If you looked closely at the screenshot, you may have noticed a little bit more Base64 poking out at the bottom of the script. This is what we're after. This is the chunk that contains shellcode used to communicate with the Cobalt Strike C2 Server itself.

### Decoding Base64 + XOR

Unfortunately, this isn't straight Base64, we cant just decode the shellcode and all will be well in the world. It's never that simple. Fortunately, it's almost as simple as our "From Base64, Gunzip". We simply have to scroll down to the bottom of the file to find that our shellcode is actually XORed with a key of 35.

![[Pasted image 20220629181216.png]](https://blog.spookysec.net/img/Pasted image 20220629181216.png)

Pivoting over to CyberChef, we can easily remove "Gunzip" and replace it with XOR. One thing I always found tricky about XOR is the format that the key is. In PowerShell, its **decimal**, not hex. You can find the [Recipe here](https://gchq.github.io/CyberChef/#recipe=From_Base64('A-Za-z0-9%2B/%3D',true,false)XOR(%7B'option':'Decimal','string':'35'%7D,'Standard',false)).

![[Pasted image 20220629182045.png]](https://blog.spookysec.net/img/Pasted image 20220629182045.png)

After setting the key to Decimal, we should see a MZ header... Or one would think? Oh wait, it is there! It's just a few bytes off.... But what are those bytes exactly?

![[Pasted image 20220629182558.png]](https://blog.spookysec.net/img/Pasted image 20220629182558.png)

### Saving and Parsing the Beacon

Oh, interesting. It's a NOP Sled! I don't think I've ever seen that before. Anyways - Now that we have the binary executable, let's Download it from CyberChef by clicking the "Save Output to File" icon.

![[Pasted image 20220629182736.png]](https://blog.spookysec.net/img/Pasted image 20220629182736.png)

You will be prompted to name the file, I kept it "download.bin". On Kali, I cloned Sentinel One's Cobalt Strike Beacon Parser which can be found on [GitHub](https://github.com/Sentinel-One/CobaltStrikeParser). This tool can be used to do exactly that! Parse Cobalt Strike Beacon Configs. Let's run it against our executable and see what happens.

![[Pasted image 20220629183039.png]](https://blog.spookysec.net/img/Pasted image 20220629183039.png)

And... It works! We can see where the beacon is sending data to (solvesalesoft[.]com:8080/af). 

Knowing this, there's tons of *interesting* things we *could* do. Unfortunately, decoding traffic is not one of them. The PCAP contains SSL/TLS streams that were not MITM'd, so our analysis stops here... Unfortunately, we will never know exactly what data was stolen. Though, I'd like to give a shoutout to [Didier Stevens](https://blog.didierstevens.com/) for making some awesome tools to parse information out of [Cobalt Strike](https://blog.didierstevens.com/programs/cobalt-strike-tools/)  beacons, PCAPs, memory dumps, and much more. This helped in a CTF recently where we did have a PCAP where we could read the traffic to the C2 server. I'll be posting a writeup of that challenge shortly - consider this post a primer.

Anyways - I hope you enjoyed and possibly learned something new!

~ Ronnie
