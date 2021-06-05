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

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">did someone say Evade All The Things?<br><br>I even ran it on my host PC with no detections 🥲<br><br>never did I think I would see Meterpreter not get picked up on my machine w/ AV enabled <a href="https://t.co/IbHHjhPCzi">pic.twitter.com/IbHHjhPCzi</a></p>&mdash; Banana (@NekoS3c) <a href="https://twitter.com/NekoS3c/status/1397756594637713413?ref_src=twsrc%5Etfw">May 27, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

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

**My thought's and opinions** - I'm very in favor of individuals in Information Security holding a Networking Certification and I think the CCNA is the **best** networking certification you can take for the money. However, as a Bonus I'll include a couple of **free** certifications you can take later on in the post :)

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

