---
layout: post
title: Certification Talk
gh-badge:
  - star
  - fork
  - follow
tags:
 - Certification
 - Cyber Security
comments: true
published: true
date: '2020-07-10'
---

A Common question I get asked is "What do you think of this certification?", "Should I do X certification or Y certification?", "What's the difference between X and Y certficiation?" and many others. With this blog post, I'll try to cover the pros and cons for each of the certifications I've taken.

### What certifications have I taken?

As of 6/5/2021, I've taken the following:

A+, Security+, CySA+, PenTest+, Network+, CCENT, CCNA R&S, CCNA CyberOps, OSCP, OSEP, CRTO, OSWP, GNFA, and CEH.

For the sake of time, I'm going to remove CCENT and A+ for this list, since they don't hold a lot of value when looking for a job in an Information Security oriented role.

# Penetration Testing/Offensive Security Certifications

## Offensive Security

Offensive Security is well known for their certifications, and for a very good reason. They offer a very unique approach to learning with a methodology of "Try Harder". This basically means "Try to learn it on your own. People aren't always going to be there to hold your hand". This isn't always the case, but it does teaches you to build a very important work ethic that is required for you to succeed in InfoSec.

### PEN-300/OSEP

**Cost - $1,300 - $1,499**

**PEN-300** - The PEN-300 course comes with a total of 18 sections ranging from Active Directory Attacks to Building your own custom Payload droppers, Shellcode injectors, and evading Enterprise AV. Included in the course, there's over 20 hours of video content and a 700+ page PDF that goes along with the videos. The PDF tends to go into a little bit more detail than the videos.  The course has an extremely heavy emphasis on evading Anti-Virus which is super useful in the real world. It's proved useful where several times I was able to evade my host AV. No other course has taught me to do this. This by far is one of the key value points of this course.

<center><blockquote class="twitter-tweet"><p lang="en" dir="ltr">did someone say Evade All The Things?<br><br>I even ran it on my host PC with no detections 🥲<br><br>never did I think I would see Meterpreter not get picked up on my machine w/ AV enabled <a href="https://t.co/IbHHjhPCzi">pic.twitter.com/IbHHjhPCzi</a></p>&mdash; Banana (@NekoS3c) <a href="https://twitter.com/NekoS3c/status/1397756594637713413?ref_src=twsrc%5Etfw">May 27, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script></center>

**OSEP** - Starting the Exam, you're presented with a small engagement note that outlines the objectives of the exam -- You have to achieve one of two goals, either get Secret.txt or gain 100 points. In my experience, there's no way to tell which path you're going down until you get there. I achieved getting Secret.txt, however, I was fairly close to 10 machines by the time I got Secret.txt. It took me approximately 8 hours to achieve the exam objective split up across 17 hours. I started my exam at 10:00pm EST on a Sunday night and slept at 2:00am EST. I had woke up at around 12:00PM EST the next day and wrapped up at around 3:45PM EST. I was able to submit the report a minute under the 24 hour mark, so as long as you don't get caught up for too long in any particular point, 48 hours should be more than enough.

In terms of coverage of content on the exam, everything in the PDF should be considered fair game. The 6 challenges in the labs do adequately prepare you for the exam, I'd highly recommend writing practice reports on challenge 3-6, just so you're familiar with the format. I treated it very much like a real engagement with an Executive Overview, Testing Narrative, and individual step-by-step walkthrough on how to compromise and escalate privileges on each machine. This certification exam is by far (aside from OSWP) the most fair exam OffSec offers to date. It's so much more fair (by a longshot) compared to OSCP and has a huge amount of real world relevance.

**My thoughts and opinions** - This is one of the best courses that I have taken in the past few years. There's only a few things I would have liked to see in this course. I really would have liked to see NTLM Relaying, Password Spraying, LLMNR Poisoning, Compromising VPN Portals, and other topics relating to compromising the identity.

### PEN-200/PWK/OSCP 

**Cost - $1000 - $1349**

**PWK** - When you sign up for PWK (Penetration Testing with Kali, the course **required** for the OSCP) you get to pick a start date for your course material/lab start date to start on. The course material comes with an approximately 800-1000 page PDF and around 18-25 hours worth of video content covering basically everything you need to know to be a junior penetration tester. The new course materials are fantastic and are 100% worth the extra $200. The labs on the other hand offer an incredibly well built environment that you can use to test the tools you learned to exploit a network comprised of 50+ hosts.

**OSCP** - The certification is a 24-hour hands on exam where your goal is to comprimise 5 various hosts in a network. Each host is worth a certain point value, totalling 100 points. You need a combination of 70 points total to pass. Following the exam, you have an additional 24-hours to write a report on the hosts you comprimised in the exam. If Offensive Security's grading team deems your report is satisfactory, then you pass the exam and earn the OSCP certification.

**My thoughts and opinions** - I think that the OSCP is one of the best certifications to have if you're looking to start a career in Information Security.

### WiFu/OSWP

**Cost - $450**

**WiFu** - WiFu is an amazing introduction into the Aircrack-NG suite. If you're not familiar with Aircrack, or Wireless Attacks, then this is a really good certification/course to start with. The video material totals about 4 hours worth of content and the PDF is approximately 300-400 pages. The PDF is incredibly useful for referencing topics about 802.11.

**OSWP** - The certification exam is a 4-hour practical exam where your goal is to comprimise 3 wireless networks through various attack vectors with your goal to expose the WEP/WPA/WPA2 key used to access the network. Following the exam, you have an additional 24 hours to submit a report on how you comprimised the network.

**My thoughts and opinions** - I think that the course/certification is a great introduction to Wireless Testing. I don't believe that the certification is overly challenging (as I finished my exam with 3 hours to spare...), but I do think that its a testimate to how comprehensive the course materials are. The course materials are a little out dated, but in Offensive Security's defense, wireless testing hasn't changed that much.


## CompTIA

CompTIA is a vendor neutral, non-profit Certification body designed to help improve the broad knowledge of individuals looking to advance their career in Information Technology.

### PenTest+

**Cost - $233 - 359**

**Courseware** - Courseware is unfortunately not provided for the course. CompTIA does offer official training material for an aditional $190 (Totalling $549). I have not seen the official course material for this certification, but my personal recommendation is to check out Wiley's PenTest+ Study Guide (ISBN: 978-1-119-50424-5)  for $40.

**PenTest+** - The exam covers a wide variety of topics that not a lot of exams hammer. The biggest one that I had noticed was management (of a Penetration Test). Speicfically, there were a lot of things I found that I didn't know by taking this exam. This personally helped me identify my weaknesses, which I consider a win.

**My thought's and opinions** - This certification exam isn't valued yet. It doesn't hold weight in the DoD (yet), and that would be its saving grace. It's only been out for approximately 2 years with [CompTIA fighting to get it recognized](https://www.comptia.org/blog/why-comptia-pentest) for the DoD 8570.01-m. If it were to get accepted, [according to CompTIA](https://www.comptia.org/blog/what-is-dod-8570-certifications) it would satisfy requirements for CSSP Incident Responder and CSSP Auditor. If you're a student, I would highly recommend you pick up the educational voucher for $233.

## Zero Point Security

Zero Point Security is a company owned and operated by RastaMouse - The one and only. He had developed Rasta Labs and now a new Training course, CRTO.

### Red Team Ops / CRTO (Certified Red Team Operator)

**Cost - $500+**

**Courseware** - Upon purchasing the CRTO course, you will recieve an invite to the Zero Point Security Canvas platform where all the course material is located. You get to keep access to this **for life**, and will recieve **all future updates for free**. Though, if you would like to purchase extra lab time, it will cost you a steep additional fee. Though, the lifetime access to the course material is worth it in itself. Both Covenant and Cobalt Strike are taught in the course, making it useful as a C2/AD Attack reference guide if nothing else.

**RTO Exam** - This exam was an amazing experience, it covered just about all Active Directory attack techniques mentioned in the course. It's equally rigerous as the OSEP, the only difference is when it comes to AV Evasion, you're on your own :). It is highly advised you use a C2 in the exam environment otherwise you'll be knee deep in RDP sessions. You need to earn a total of 3 out of 4 flags to pass the exam, which is more than possible. I achieved 4/4 flags in under 10 or so hours. I didn't actually know you needed only 3/4 flags until i was knee deep in RDP sessions because I made the poor decision of using Metasploit as my C2 lol. Use CS or Covenant. It'll save you so much time. No report is required for this one.

**My thought's and opinions** - The exam was great. Between this and OSEP, I couldn't ask for a better Red Team Training experience. There were (like I previously mentioned with OSEP) a few topics that were missing, but that's okay. The amount of value you get from these two courses is insane. 100% would recommend RTO.

**NOTE**: You need to pass the RTO exam and the RTO course to obtain the CRTO Certification.

## eLearnSecurity

eLearnSecurity is one of the newest kids on the block in terms of Security Certifications, they've been on the market for about 3-4 years now, recently they were bought by INE which has raised a large number of concerns regarding quality in the Cyber Security community.

### PTS/eJPT (PenTest Student/eLearnSecurity Junior Penetration Tester)

**Cost - $200**

**Courseware** - INE Provides the courseware for free, if you would like to use David Bombal's affiliate link, feel free to click this link <a href='https://bit.ly/freeinetraining'>https://bit.ly/freeinetraining</a>, else you can get it <a href='https://checkout.ine.com/starter-pass'>here</a>. The starting path grants access to the course material and labs needed to pass the exam.

**eJPT** - The exam itself is relatively straight forward, it consists of 20 multiple choice questions which you can get 5 wrong. Multiple Choice questions are a really bad format for this exam, to be honest. It gives away way too much information about the assessment and can point you in the direction to try certain things. As long as you have common sense, you can really do the exam while never touching the course material. Especially with the time limit provided. They also feel the need to introduce the concept of adding routes to your local routing table to access other parts of the network which is **incredibly** unrealalistic. In my almost a year and a half of professional penetration testing, there has **never ever** been a scenario where I have needed to **manually** add a route to my local routing table. This is an utterly pointless part of the exam that seems to be a trend in their exams.

**My thoughts and opinions** - The format here really needs to be changed, though I know why they do it the way they do. eLearnSecurity uses Multiple Choice Questions on the eJPT exam to provide instant feedback, where as their higher level certifications can take **upwards of a month** to get the results back. Personally, I think a power point briefing on the vulnerabilities identified during the mock "Penetration Test" would be much better and easy to grade. "Did they locate X vulnerability during the assessment? Y/N, award points, don't award points". Simple and easy and could prevent a fair amount of answer sharing/cheating. Cheating is another thing to mention -- the eJPT exam is completely unproctored meaning you have full open internet access where you can contact whoever you like, even search for the answers of the exam. Obviously, this only hurts yourself and can be said for any unproctored assessment, however, this seriously devalues the certification in my mind. There's a grand total of 14 jobs (at the time of writing 6/05/2021) on LinkedIn in the United States asking for this certification, most are duplicate positions located in different areas by the same firms. I'm going to say this only once -- Penetration Testing isn't an entry level field. If you're going to go -- go all the way to OSCP. Save your money.

### PTX/eCPTX (Penetration Testing Extreme/eLearnSecurity Certified Penetration Tester Extreme)

**Cost - $200 - $400** 

**Courseware** - Courseware is not provided with the Exam Voucher. It is a seperate fee of either $750 (**labs included**) a year or $500 a year (**no labs included**) a month. It's important to note that this grants access to all INE material. I have purchased the course material and I strongly dislike it. The format provided (videos, power point, text, labs, etc) are all of very poor quality. After eCPPT, one would think the next step (eCPTX) would cover more red teaming topics, like in depth Active Directory attacks, phishing, Anti-Virus evasion, etc, they would be wrong. This is yet another extension of eLearn's poorly written Pentesting content. If you want an actually valuable resource to learn Active Directory, check out <a href="https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse">iRedTeam</a>, <a href="https://attack.mitre.org/">MITRE ATT&CK</a>, <a href="https://adsecurity.org/">ADSecurity</a>, and <a href="https://dirkjanm.io/">Dirk-Jan Mollema's Website</a>.

**eCPTX** - Oh man, I've got a bone to pick with this one. To start off, you're given a letter of engagement that outlines the exam as a **Red-Team Engagement**. Not a Pentest, despite the certification's title. This is **not** a Red Team exam. You're given an initial scope to begin enumeration with goals of Identifying all internal subnets, all internal machines and servers, and forests. You are **restricted** from using **any** exploits within the exam. You must "Operate stealthily like an advanced adversary, leverage insecure Active Directory (or host) configurations and abuse trust relationships ONLY.". This is mentioned many times  throughout the 5 page letter of engagement. This is an incredibly large conflict, as I study APTs at my day job and APTs sure as hell use exploits to gain initial access to internal networks and to compromise hosts. This article from <a href="https://www.bleepingcomputer.com/news/security/fbi-apt-hackers-breached-us-local-govt-by-exploiting-fortinet-bugs/">Bleeping Computer</a> provides a perfect example of how APTs abused a CVE to gain access to an internal network. Additionally, Microsoft reported on numerous attempts to abuse Zero Logon shortly after its publication with metrics directly from Azure ATP. See the tweet below:

<center><blockquote class="twitter-tweet"><p lang="en" dir="ltr">MSTIC has observed activity by the nation-state actor MERCURY using the CVE-2020-1472 exploit (ZeroLogon) in active campaigns over the last 2 weeks. We strongly recommend patching. Microsoft 365 Defender customers can also refer to these detections: <a href="https://t.co/ieBj2dox78">https://t.co/ieBj2dox78</a></p>&mdash; Microsoft Security Intelligence (@MsftSecIntel) <a href="https://twitter.com/MsftSecIntel/status/1313246337153077250?ref_src=twsrc%5Etfw">October 5, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script></center>

This is a huge conflict in my opinion. Adversaries use exploits **all the time**, yet we're not suppose to use in this environment. Another important thing to note is that eLearnSecurity does not regularly patch their exam environment like other vendors. I contacted them about this issue directly (along with one other that I'll get into in a few moments) and their response was "We're aware these exploits exist, however the letter of engagement says you can't use them anyways". Which is one hell of a response... I could actually use the level of access gained to turn this from a black box assessment into a white box assessment because I would have gone from zero credentialed access to full control of the Domain in under 30 seconds where I could then sign into **any** device, look for any user interaction scripts, identify lateral movement paths from Bloodhound, and essentially make the exam easier on myself. If I wanted to know what the intended attack path is, or if there were any intentional interaction scripts, I could sign into the box, look, then test my attack. That's a huge issue. I could also not report that I used this and leave it redacted from the report because like the rest of eLearnSecurity exams, it's not proctored.

It's worth noting as well that with NTLMRelayX, with the -t all://ipaddress, NTLMRelayX will attempt to auto exploit certain Active Directly configurations (which was stated was against the exam rules, while they encourage the use of this tool)...  

Lastly, and probably the biggest concern that I found while doing the exam is the use of a program called "KMSpico" - a Windows/MS Office activation tool that is **in no way associated or affliated with Microsoft** that promises you never pay anything, doesn't have viruses, and is "legal" for testing purposes, which is infact, not true. KMSPico is notorious for activating Windows without paying for it. When confronted with this, their response was the following:

```
KMSPico: INE/eLS are VERY STRICT in terms of licences, I myself had to wait before starting to design any lab for them. As you can see in our website ,we are training providers for Microsoft and the reason of this program being here it’s not the lack of licenses itself. The decision to use this program was made by our devops and/or director and the most probable reason is to prevent legit licenses been leaked or stolen from boxes designed to be fully compromised. Whatever the reason is, I trust that my company and team made the right and absolutely legal decision and, of course, as far as I’m concerned licenses are there. We are a billion dollar company, software piracy for saving a few dollars it’s not something we do. 
```

Microsoft in no way would ever advise to use a third party licensing tool like KMSpico, especially since their documentation tells you exactly how to set up and configure it:
https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys and https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/dn502531(v=ws.11)

Interpret this how you will, I see here that they did not take the right way to license the devices, as a legitimate On Prem KMS server could be used to license this, however, it wasn't. For example, AWS has their own KMS Server (Instructions provided here: https://aws.amazon.com/premiumsupport/knowledge-center/windows-activation-fails/ ) so all servers and clients are licensed properly... I have reported this to Microsoft as well as I'm sure they wouldn't like INE's response.

**My thought's and opinions** - As I'm sure you can tell, this whole experience has left me very unimpressed. This isn't a Red Team exam, this isn't well maintained, and I'm not quite sure it's even legal. I made the decision to **not** submit the exam report, because I felt that if this was a more well known thing, it would leave a negative reputation across all eLearnSecurity certification holders. I have chose to take these certifications but have not submitted/passed the exams due to the information described above. I apologize for the incredibly long section on this one, the rest are much shorter. I promise.

# General Security Certifications

## EC-Council

EC-Council is a renound organization thanks to the DoD, they offer several well known certifications such as C\|HFI (Certified Hacking Forensics Invesitigator), E\|CIH (Certified Incident Handler), and C\|EH (Certified Ethical Hacker) amoung many others. They also offer several degree programs through EC-Council's University program.

### CEH

**Cost - $1000 - 2000+**

**Courseware** - CEH is an okay introduction to a broad overview of Ethical Hacking. The PDF courseware is over 4,000 pages with the lab manual included, and the labs offer coverage in 20+ different topics. The courseware is nowhere near as intensive as Offensive Security and does not teach you how to become a penetration tester or security professional properly. A lot of non-free Windows tools are covered that I strongly disagree with. There isn't a large emphasis on Linux that there needs to be. A lot of web attacks and exploits are missing.

**CEH** - The exam is a 4-hour long exam comprised of 125 questions. The formatting of the exam was horrible. It's an online proctored exam with multiple choice questions. 

**My thought's and opinions** - Some information is technically inaccruate, containing tools that haven't been implemented in 4+ years, despite the exam being released in 2018. There's no excuse for these questions to still be in the pool and is the primary reason that I can't recommend it to anyone. Several questions (and the formatting) actually horified me. The proctor was helpful to direct me on where to point me to about the technically inaccurate questions at least. The only reason I would ever recommend getting this certification is to bypass HR requirements. You can forget everything the course taught you, and you'd be better off. PWK/OSCP or eCPPT are far better purchases that will teach you far more technically accurate and useful information.

## CompTIA

### Security+

**Cost - $221 - 349**

**Courseware** - The Courseware is not provided, but is avalible for an extra fee, upping the price by $150 bringing the total up to $499. As always, I believe the course material falls a bit short, so I highly suggest opting for a second source, and I still recommend Wiley's Security+ Study Guide for $27 (ISNB: 978-1-119-41696-8)

**Security+** - The exam itself can be difficult for newcommers into Cyber Security, and vetrans if they're not use to the way that CompTIA asks their questions. If you know the course material well, you should be able to pass the exam with ease.

**My thought's and opinions** - This certification is a really good introduction to Security. I think it's a standard for Information Security and everyone working in Security should have attempted it, or at least have it.

### CySA+

**Cost - $233 - 359**

**Courseware** - As always, CompTIA does not include courseware, but you can purchase the option with courseware for $549, so like PenTest+, an extra $190. I don't have any personal recommendations on what study material to use for this certification because I the Beta exam without studying, however, Wiley's books have traditionally been good.

**CySA+** - As previously stated, I took this exam while it was in the Beta, so my mileage will have varied from yours. The single biggest topic that I would recommend is that you know the exact process of detecting Malware, and removing it from the system.

**My thought's and opinions** - I'm not exactly sure who this certification is for, right now I work on a Blue Team and a lot of the topics covered on the exam, I'm not actively using in my job role. So I'd say there was no benefit to the exam, However, what I would suggest is if the opportunity arises, you should take the Beta exam for only $50.

# Networking Certifications

## Cisco

Cisco is one of the most renowned Networking Equipment vendors and own about 60-70% of the Networking market. As a Penetration Tester, you will **always** see a Cisco device in just about every network you touch. It's incredibly common to see a Cisco ASA SSL VPN on an engagement, and I'd highly recommend knowing the underlying technologies that it runs on.

### CCNA

**Cost - $150 - 300**

**Courseware** - Traditionally, Cisco does not provide courseware with their Certifications, however, they do offer Cisco Networking Academy which is their own training that I can say with confidence is up to a high level of standard and will adequately prepare you for the CCNA certification exam. If you take the CCNA level courses through Cisco, you may be eligble for a discount on the exam voucher if you score high enough on the Final Exam.

**CCNA** - I took the CCNA when it was still CCNA R&S and not on the new CCNA branch. There are a ton of new topics that are very important such as Network Automation, Access APIs, and SDN. These are all key topics in the evergrowing Industry. I highly recommend taking a Networking certification, and if you choose to take one, the CCNA is an excellent choice.

**My thought's and opinions** - I'm very in favor of individuals in Information Security holding a Networking Certification and I think the CCNA is the **best** networking certification you can take for the money.

### Cyber Ops Associate (CCNA CyberOps)

**Cost - $300**

**Courseware** - No courseware was included with the Certification exam and or attempt, however, Cisco does offer Course Materials for sale through their <a href="https://www.ciscopress.com/store/cisco-cyberops-associate-cbrops-200-201-official-cert-9780136807834">Website</a>. Cisco always does a decent job with their 

**Cyber Ops Associate** - The certification was incredibly fair, there was a relatively wide variety of attacks, analysis scenarios, and Frameworks covered on the exam. It's a great Analyst for a SOC certification. I have also taken CyberOps professional and can say it's not exactly as fair as CyberOps associate. I don't think it has much real world value as CyberOps Associate.

**My thought's and opinions** - I'd highly recommend this certification to a SOC Analyst who's looking to add onto their career. 
## CompTIA

### Network+

**Cost $159 - 329**

**Courseware** - As always, if you wish to purchase Course Material for the certification exam, it's going to cost you an extra $130 bringing the total cost up to $449. Again, I would recommend checking out the Wiley Network+ Study Guide (ISBN: 978-1-119-43226-5) for $33.

**Network+** - This certification is very light on certain topics, the biggest one in my opinion is Subnetting, it needs be covered more and in-depth with other topics like VLSM (Variable Length Subnet Mask). A lot time in my opinion is wasted on questions that have to deal with rare and obscure technologies.

**My thought's and opinions** - This certification is for *someone*, I think that person is a beginner, absolute begineer looking to get familiarized with networking and networking technologies. I wouldn't recommend it to many people.

# Bonus: Free Courses/Certifications/Certificates of Completion 

## Fortinet

### NSE1/2

To get each of the certifications for free, you'll need to register an account with [Fortinet](https://training.fortinet.com/login/index.php?saml=off). From there, you'll want to take the course: "The Threat Landscape" which goes along with NSE1 and "The Evolution of Cybersecurity" which goes along with NS2. These courses can teach you some basics of Cyber Security as well as a couple of Certificate of Completeions


## Juniper

### JNCIA-Suite

**UPDATE 6/5/2021**: This is no longer free.

Juniper is offering all their Associate level certifications for free at the moment with the [Juniper Open Learning platform](https://learningportal.juniper.net/juniper/user_activity_info.aspx?id=11478). All the free certifications you can take are offered here:

[Junos Associate (JNCIA-Junos)](https://cloud.contentraven.com/junosgenius/DirectLaunch?cid=5DokJhgvKS0_&io=8BnvF5iFNjo_&md=IS2TIgXikDA_)
[Security Associate (JNCIA-SEC)](https://cloud.contentraven.com/junosgenius/DirectLaunch?cid=4XSCEPs2BO4_&io=8BnvF5iFNjo_&md=IS2TIgXikDA_)
[Cloud Associate (JNCIA-Cloud)](https://cloud.contentraven.com/junosgenius/DirectLaunch?cid=5hHi3V1wjk4_&io=8BnvF5iFNjo_&md=IS2TIgXikDA_)
[Automation and DevOps Associate (JNCIA-DevOps)](https://cloud.contentraven.com/junosgenius/DirectLaunch?cid=PlQPN0h0gj4_&io=8BnvF5iFNjo_&md=IS2TIgXikDA_)
[Design Associate (JNCDA)](https://cloud.contentraven.com/junosgenius/DirectLaunch?cid=vZPT0wGSf%2fc_&io=8BnvF5iFNjo_&md=IS2TIgXikDA_)

The conditions are that you take the Open Learning course and pass the exams associated with them. It's relatively easy and can give you a handful of Juniper Certifications for free.

## Splunk

### Splunk Fundamentals 1

[Fundamentals 1](https://www.splunk.com/en_us/training/free-courses/splunk-fundamentals-1.html) is a free course offered by Splunk aimed at teaching a user how to use, install, and manage Splunk on a basic level. If you're interested you can explore their certifications path, it starts with Fundamentals 1 which after the exam will grant you the Splunk Core Certified User. 
