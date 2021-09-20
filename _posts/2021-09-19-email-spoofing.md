---

layout: post

title: Email Spoofing - A Full Guide

gh-badge:

- star

- fork

- follow

tags:

- Phishing

- Penetration Testing

- Cyber Security

comments: true

published: true

date: '2021-09-19'

---

Hello Dear Readers!
Welcome back to another blog post by yours truely. Today we're going to be talking about Email Spoofing, Phishing, Forensics and all that fun stuff. Before we begin, I'm going to preface this with very large disclaimer.

**Disclaimer**: what you do with this knowledge is not my responsibility. You can and will get in trouble for spoofing emails and phishing people. This is not a joke. This is not funny. This is a serious topic and should be treated like one. The purpose for writing this article is to bring awareness to businesses that this is a real threat and for the sake of their **customers** and their **employees**, they should re-consider their DMARC/SPF DNS records.

Now that this is out of the way, let's get into it.

### How do you send an email?

What a great question! To understand all of this article, we first need to understand how sending and recieving emails work. Sending and recieving emails is a fairly simple process, if you log into your corporate outlook email and press the compose button, add a recipient, subject and body and fire it off, it will be shot out to your companies email server on port 25 or 587. These ports are known as SMTP, or Simple Mail Transport Protocol. The whole entire purpose of SMTP is to just send emails. 

Note: If you're using Port 25, you're automatically doing a bad. Port 25 is unencrypted and the contents of your email as well as your username and password are all in clear text! Oh no! So just use port 587. It's not that much more difficult to use. Always make sure you're usiong encrypted protocols or else bad things can and will happen. You have been warned.

Great, so now we know about SMTP, what does sending an email on the procotol level look like? Well, it's actually suprisingly simple. Wikipedia was kind enough to outline a simple conversation with a Postfix SMTP server, here's the conversation:

```
1. Server: 220 smtp.example.com ESMTP Postfix
2. Client: HELO relay.example.org
3. Server: 250 Hello relay.example.org, I am glad to meet you
4. Client: MAIL FROM:<bob@example.org>
5. Server: 250 Ok
6. Client: RCPT TO:<alice@example.com>
7. Server: 250 Ok
8. Client: RCPT TO:<theboss@example.com>
9. Server: 250 Ok
10. Client: DATA
11. Server: 354 End data with <CR><LF>.<CR><LF>
12. Client: From: "Bob Example" <bob@example.org>
13. Client: To: "Alice Example" <alice@example.com>
14. Client: Client: theboss@example.com
15. Client: Date: Tue, 15 Jan 2008 16:02:43 -0500
16. Client: Subject: Test message
17. Client:
18. Client: Hello Alice.
19. Client: This is a test message with 5 header fields and 4 lines in the message body.
20. Client: Your friend,
21. Client: Bob
22. Client: .
23. Server: 250 Ok: queued as 12345
24. Client: QUIT
25. Server: 221 Bye
```
Source: Simple Mail Transport Protocol via [Wikipedia](https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol)

Now, let's break it down. The first thing to know is that you don't actually need any special tools to  interface with a SMTP server -- all you need is Netcat or Telnet.

So picture this, you've just typed in ``telnet smtp.example.com 25``, the server sends back Line 1. Now it's your turn to introduce yourself! Say Hello! Seriously! that's what the server wants. It wants to know who it's talking to, more specifically what server it's talking to so it can identify if it's allowed to recieve your email*. After you tell it ``HELLO server.example.com`` (Line 2), it'll great you back (Line 3)! How nice of it. This is pretty universal in terms of Mail servers. At this point, you could view the help options by just typing ``HELP`` in, if you're concerned about Opsec, you can always google a [SMTP cheatsheet](https://mailtrap.io/blog/smtp-commands-and-responses/).

Now, we're going to tell the SMTP server that we want to send an email, in this case, the email (on Line 4) is going to bob@example.com, The SMTP server knows you're ready to send an email because of the  ``MAIL FROM:`` that you just sent it. On Line 5,7,8, the server seems game, it does not confirm or deny that this is okay. Just that the server acknowledges the request, this is important to remember. On Line 6 and 8, we tell the server we want the recipient to be ``alice@example.com`` and ``theboss@example.com``. Once you've submitted all the "important" stuff, it's time to tell the server that you're ready to prepare the email and send ``DATA`` (Line 10). The server tells you the delimeter that it's expecting after you've finished writing the actual email itself, the specific delimeter in this case is ``.`` on a fully empty line.

So here's the interesting bit -- you're actually writing the email itself. Headers and all. If you go to your email inbox right now, click on a message, find the "options" setting and hit "Show Original", you'll actually see a bunch of information. Most of this data is added after you send the email itself. A lot of it is actually very useful in Digital Forensics, we'll get into this later.

Here's an example from my Inbox -- doesn't the Date, From and To look familiar? (see Lines 13-16)
![[https://blog.spookysec.net/img/Pasted image 20210919180316.png]](https://blog.spookysec.net/img/Pasted image 20210919180316.png)

You can pretty safely ignore the rest of the headers (ex. Message-ID, MIME-Version, Content-Type, X-eBay-MailTracker, and Feedback-ID.) All of those other stuff is added by other mail servers for tracking/marketing purposes and being able to display HTML elements. It's pretty neat.

Here's an example of an email sent by me recently. It's a lot more trimmed down and only has one-two extra headers, those being --0000 and the Content-Type. These are pretty standard, but afterwards we have the raw content of the email itself, as shown on Lines 17-21.
![[https://blog.spookysec.net/img/Pasted image 20210919180650.png]](https://blog.spookysec.net/img/Pasted image 20210919180650.png)

Afterwards, you would have seen my name, then the end of the email. Shortly after my name, the SMTP server recieved that "End of Email" character ``.`` (Line 22). Lastly, the server queued up the message for it to be sent (Line 23), and shot it off to a IMAP/POP3 server to be delievered to the client. It's important to know what IMAP and POP3 are -- they are the "Mail Delivery Protocols". These are how mail gets sent between mail servers. IMAP being the Internet Message Access Protocol and POP3 being the Post Office Protocol. There's a few slight minor differences between the two protocols, but at it's core, it's designed to transport mail server from the server to the client.

So, that's it -- that's pretty much how sending an email works.

\* We'll go into details on SPF records later, but this is where a mail server would check if it's allowed to recieve and send your email.

### Adding on Security (SPF)

Security, as you can see above, clearly was not thought of when SMTP was created, you could simply tack in any sender you pleased. As the Internet grew larger and larger in 2006, several researchers (M. Wong and W. Schlitt) drafted [RFC 4408](https://datatracker.ietf.org/doc/html/rfc4408). This is better knwon as Sender Policy Framework (SPF) for Authorizing Use of Domains in E-Mail, Version 1. This RFC proposed a new use of TXT records, this being SPF. Later on, SPF would get it's own record type, but you might still see some companies use TXT for SPF records, sort of like an Alias, but fundamentally they work the same way.

So I've babbled on a bit about SPF records, but what does it actually do and what does it actually mean?

Well, not a whole lot actually. SPF in itself can be fairly useless if DMARC records aren't configured. It validates who can send an email from the specified domain, this is normally shown in the form of an IP Address or Network Address blocks, but is not limited to that -- it can also be a Domain Name. Generally, the less IPs you have the better. For larger companies with multiple mail servers, this isn't always possible. Hulu has a reasonably sized record list, so we'll use this for a breakdown -- here's their SPF record:

```
v=spf1 
ip4:199.60.116.119
ip4:209.177.166.1
ip4:209.177.166.33
ip4:8.28.125.14
ip4:208.91.156.34
include:spf.protection.outlook.com
include:spf-002b4c01.pphosted.com
include:servers.mcsv.net
include:_spf.salesforce.com
include:_spf.google.com
-all
```

Let's go line by line again and break it down. On line 1, we get to see the version of SPF that Hulu is using. In this case, it's version 1. Nothing is wrong with that. Lines 2-6 outline the IP addresses (199.60.116.119, 209.177.166.1, 209.177.166.33, 8.28.125.14, and 208.91.156.34) that are authorized to send Email. These aren't the only hosts that are authorized to send an email, though. Lines 7-11 also allow Outlook, Proofpoint, Mail Chimp, Sales Force, and Google to send emails on their behalf. If you lookup those records you'll see several ranges of IP Addresses that are authorized to send emails as well. This could potentially widen the attack footprint majorly. 

Lastly, you'll see ``-all``. This means that if the IP Address isn't matched in their list, the email should be rejected. This is starting to boarder a bit into DMARC records, but we'll keep going. There's several other options this could be as well -- ``+all`` and ``~all``. ``+all`` means that even if Mail came from a server not in that list, it would be allowed to pass through. ``~all`` on the other hand means a Soft Fail, so it'll look to the DMARC records to decide the fate of the email.

### Adding onto Security Part Deux (DMARC)

Many years later, in 2011 the first draft of the DMARC record was created. So what is this new RFC that's being proposed? It's a cool new DNS record called DMARC, which stands for the Domain-based Message Authentication, Reporting, and Conformance. If you're like me, you read that and thought "Well, that's a whole lot of words, what's it all mean?". 

Let's break it down -- Domain Based Message:
1. Authentication -- Is used in combination with existing SPF records to tell the mail server who is allowed to send mail
2. Reporting -- Is used for forensics purposes. If the SPF record or DMARC record fails, it will email the results off to a specified email address
3. Conformance -- It's aiming to standardize Anti-Email Spoofing technologies to fall under one  easy to use technology called DMARC records.

Now that you hopefully have a little bit better of an understanding, we're going to take a look at some DMARC records:

```
v=DMARC1; 
p=quarantine; 
adkim=r; 
aspf=r; 
pct=100; 
fo=1; 
rua=mailto:dmarc_rua@emaildefense.proofpoint.com
```

As you can see, it looks fairly similar to the previous SPF records, but this time it has semi colons! Yay!!!

Jokes aside, it's pretty similar.  Like last time, ``v`` outlines the version used, in this case it's DMARCv1. Next up is ``p`` what happens when an email fails to validate SPF records -- in this case it will Quarantine the email and send the email to the users Spam inbox. There's a total of three possible types the ``p`` value can be, one being Quarantine, the next being Reject, and the last one being None. Next up is a few forensics records, I'm not too well versed in the forensics myself, so we're going to skip these. Lastly, we have the rua variable -- this is the inbox that will recieve information about DMARC/SPF pass/fails. For more information about DMARC reports, you should check out this article by MXToolbox: [https://mxtoolbox.com/dmarc/details/what-do-dmarc-reports-look-like](https://mxtoolbox.com/dmarc/details/what-do-dmarc-reports-look-like)

So, in reality DMARC is the actual security protocol here. It dictates what happens when SPF records fail to be validated. 

### Enumerating SPF and DMARC Records

So we've talked about how emails are sent, how emails are validated against a specific list of IPs and if they're allowed into a users inbox/quarantined/failed to deliver, but how do we enumerate these records?

There's several ways! First we're going to take a look at how to do so with dig. It's fairly simple:

**SPF:** ``dig example.com txt | grep spf``

**Example Query: ** 
```
┌─[root@kali]─[~]
└──╼ #dig hulu.com txt | grep spf
hulu.com.               300     IN      TXT     "v=spf1 ip4:199.60.116.119 ip4:209.177.166.1 ip4:209.177.166.33 ip4:8.28.125.14 ip4:208.91.156.34 include:spf.protection.outlook.com include:spf-002b4c01.pphosted.com include:servers.mcsv.net include:_spf.salesforce.com include:_spf.google.com -all"
```

**DMARC:** ``dig _DMARC.example.com txt``

**Example Query:**
```
┌─[root@kali]─[~]
└──╼ #dig _dmarc.hulu.com txt | grep "v=DMARC1"
_dmarc.hulu.com.        300     IN      TXT     "v=DMARC1; p=quarantine; adkim=r; aspf=r; pct=100; fo=1; rua=mailto:dmarc_rua@emaildefense.proofpoint.com; ruf=mailto:dmarc_ruf@emaildefense.proofpoint.com"
```

None of these are very pretty, as I'm sure you can tell, so let's move onto the next method -- Using MXToolbox! MXToolbox parses records into an easy to read table for your viewing pleasure!

**SPF:** [https://mxtoolbox.com/spf.aspx](https://mxtoolbox.com/spf.aspx)

**Example Query:**
![[https://blog.spookysec.net/img/Pasted image 20210919194423.png]](https://blog.spookysec.net/img/Pasted image 20210919194423.png)

**DMARC:** [https://mxtoolbox.com/DMARC.aspx](https://mxtoolbox.com/DMARC.aspx)

**Example Query:**
![[https://blog.spookysec.net/img/Pasted image 20210919194438.png]](https://blog.spookysec.net/img/Pasted image 20210919194438.png)

As you can see, this information is much easier to comprehend, then even parse it for you and break it down and explain how you can improve your SPF/DMARC records.

Now that you all (hopefully) understand how to interpret those records, retrieve them for your viewing pleasure, we can now identify email domains that are spoofable. 

### Who on Fortune 500 Global list has a Spoofable Email?

As you should know, Spoofing is powerful, like, very powerful. Unfortunately, it's incredibly easy to do. That's why I'm going to be doing this exercise. I have found a list of Fortune 500's Global Companies for 2021 that contains each companies website. I will be using this to check against the DMARC/SPF policies to detect and see if email spoofing across each of these domains is possible.

How? 
Good question. 
Bash Scripting. It's easy and quick to do.

**SPF Check Script:**
```
#!/bin/bash
rm fortune-500-spf-records.txt
wget https://raw.githubusercontent.com/Sq00ky/SpookySec-Blog/master/fortune-500-global-websites.txt -O domains.txt
for LINE in `cat domains.txt`
        do dig $LINE txt | grep spf >> fortune-500-spf-records.txt
done

dupe=$(cat fortune-500-spf-records.txt | awk '{print $1}' | wc -l)
echo $dupe domains with SPF Records
dedupe=$(cat fortune-500-spf-records.txt | awk '{print $1}' | uniq | wc -l)
echo $dedupe dedupe domains with SPF Records

```

**Results:** [425](https://raw.githubusercontent.com/Sq00ky/SpookySec-Blog/master/fortune-500-spf-records-unique.txt) of Fortune 500 Global companies have SPF Records in place. 

75 missing right off the bat isn't necessarily good, *but* the website listed could potentially not be their primary website. Let's move onto DMARC records, this is  where (I think) the results start to fall off a bit.

**DMARC Check Script:**

```
#!/bin/bash
wget https://raw.githubusercontent.com/Sq00ky/SpookySec-Blog/master/fortune-500-global-websites.txt -O domains.txt
rm fortune-500-dmarc-records.txt
for LINE in `cat domains.txt`
        do dig _dmarc.$LINE txt | grep "v=" >> fortune-500-dmarc-records.txt
done

dupe=$(cat fortune-500-dmarc-records.txt | awk '{print $1}' | wc -l)
echo $dupe domains with dmarc Records
dedupe=$(cat fortune-500-dmarc-records.txt | awk '{print $1}' | uniq | wc -l)
echo $dedupe dedupe domains with dmarc Records
```

**Results:** [272](https://raw.githubusercontent.com/Sq00ky/SpookySec-Blog/master/fortune-500-dmarc-records.txt) domains have DMARC records configured.

Now remember, just because DMARC records *are configured,* it doesn't mean they're configured properly. Let's do a check now and see how many have strict drop spoofed emails policy.

**Drop Failed SPF check:** 110

**Quarantine Failed SPF check:** 34

**Pass Failed SPF check:** [128](https://raw.githubusercontent.com/Sq00ky/SpookySec-Blog/master/pass-failed-spf.txt)

**Email Forensic Reports:** 264 


**Note:** These numbers may be inaccurate to a degree. In further analysis some DMARC records have a sp record for Subdomains. I manually verified the Pass Failed SPF check, however. Just not Drop/Quarantinem so therefore, I am only linking the results to the domains that pass a failed SPF check.

### Testing Email Spoofing 

Now we're going to test a domain at random -- Let's try riteaid.com. For simplicity reasons, we're going to use [emkei.cz](https://emkei.cz/) -- a web based email spoofing utility.

![[https://blog.spookysec.net/img/Pasted image 20210919220505.png]](https://blog.spookysec.net/img/Pasted image 20210919220505.png)

After hitting send, checking my inbox yeilds....

![[https://blog.spookysec.net/img/Pasted image 20210919220433.png]](https://blog.spookysec.net/img/Pasted image 20210919220433.png)

Success! We have spoofed an email from RiteAid. That's suprisingly simple, wasn't it? There is indeed ways to automate this, however, for your viewing pleasure, I'm not going to test all 128 emails. Only a couple for now :)

![[https://blog.spookysec.net/img/Pasted image 20210919220810.png]](https://blog.spookysec.net/img/Pasted image 20210919220810.png)

### Forensics

So now that we've got a few spoofed emails, let's take a look at the email forensics bit.

In GMail, if you click on the "Three Dots", a collapable menu will open, within that menu, there will be a "Show Original" section.

![[https://blog.spookysec.net/img/Pasted image 20210919221019.png]](https://blog.spookysec.net/img/Pasted image 20210919221019.png)

Click on it! You should see something like this open up:

![[https://blog.spookysec.net/img/Pasted image 20210919221059.png]](https://blog.spookysec.net/img/Pasted image 20210919221059.png)

```
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning admin@riteaid.com does not designate 101.99.94.155 as permitted sender) smtp.mailfrom=admin@riteaid.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=riteaid.com
Return-Path: <admin@riteaid.com>
Received: from emkei.cz (emkei.cz. [101.99.94.155])
        by mx.google.com with ESMTPS id g24si15090995edr.84.2021.09.19.19.03.28
        for <ronnie@spookysec.net>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 19 Sep 2021 19:03:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning admin@riteaid.com does not designate 101.99.94.155 as permitted sender) client-ip=101.99.94.155;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning admin@riteaid.com does not designate 101.99.94.155 as permitted sender) smtp.mailfrom=admin@riteaid.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=riteaid.com
Received: by emkei.cz (Postfix, from userid 33) id 325C4241A9; Mon, 20 Sep 2021 04:03:28 +0200 (CEST)
To: ronnie@spookysec.net
Subject: Test
From: "admin@riteaid.com" <admin@riteaid.com>
X-Priority: 3 (Normal)
Importance: Normal
```

Above, is an excerpt from the screenshot. In here, we can see the DMARC policy **failed**. However, the policy states to do **nothing** if it fails, therefore the email is delivered with success. It's also important to note the SPF Soft Failed as well, but passes because the DMARC record is configured to allow.

The Sender domain (emkei.cz) as well as the IP Address is mentioned, so this is a key indicator (that being if the mail server is being sent from a domain that isn't the same as the sender). Additionally, the mail server (Postfix) is also mentioned, this could potentially be an indicator as well, especially if you use Microsoft email server products and not Linux. Lastly, the Timezone is a big giveaway. If your company only operates in the East Coast, United States and your timezone is GMT+8, you could potentially be dealing with a Russian threat actor!

### Conclusion

Email spoofing is ridicilously easy. Like, way too easy, it's also an incredibly simple fix that revolves knowing your assets. I always like to say "If I can send an email as your boss, **you** have a problem". 

Anyways, time to get off my soapbox. I'm sure you all can see how dangerous this can be. I hope you learned something :)
