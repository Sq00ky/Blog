---
layout: post
title: 2024 CISA ICS CTF - Modeling Trains
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

Well, another year has passed, which means its time for my annual CTF competition. This year I'm doing CISA's ICS CTF solo-mode. This CTF has some infrastructure setup for the players to use; [Malcolm](https://github.com/cisagov/Malcolm), [Arkime](https://arkime.com/), [NetBox](https://github.com/netbox-community/netbox) and [CyberChef](https://github.com/gchq/CyberChef). Some of these services we'll be using in this challenge, some won't. I'll probably put this brief little introduction in each post so we're all on the same page.

Today we're going to start off with  the Modeling Trains challenges. This is under the Anville category, so all of these are Rail/Transport themed challenges, one of the important categories of Critical Infrastructure.

![[Pasted image 20240903204214.png]]("https://blog.spookysec.net/img/Pasted image 20240903204214.png")

### Modeling Trains 1
The first challenge describes how Anville uses NetBox for inventory management. Recently, engineers have reported that there has been communication issues from Field Station 8. Our goal is to figure out what IP Address was assigned to the Station 8 Historian server.

To do this, we're going to need to open up NetBox, head over to the "Devices" tab and search for Station 8.

![[Pasted image 20240903204631.png]]("https://blog.spookysec.net/img/Pasted image 20240903204631.png")
Once there, we need to simply look for the Historian Server. Fortunately, all the devices are appropriately tagged and we can see the Historian server is a Genisys Communicator 2.0 with the IP Address of **10.230.46.201**. Looking at all the other Historian servers on the network, we can see this device was placed in the incorrect Subnet.

![[Pasted image 20240903204924.png]]("https://blog.spookysec.net/img/Pasted image 20240903204924.png")

Note that every other Historian server is in the 10.230.47.0/24 subnet while Station 8s is placed in the 10.230.46.0/24 subnet, which is likely the cause of connection issues.
### Modeling Trains 2
This brings us onto the next question - This time the Engineering team has received a request from management to provide the number of PLCs located at Station 9. Pivoting from our previous screen to Station 9, we can see there are 28 total devices at Station 9.

![[Pasted image 20240903205359.png]]("https://blog.spookysec.net/img/Pasted image 20240903205359.png")

Clicking on the "Devices" related objects will show us all the devices located at the station. A quick count reveals there's 1 Historian server, 1 Domain Controller, 1 Workstation and 25 PLCs on the site. You could Control+F to search for all the PLC devices, or just subtract 3 from 28 and get **25** remaining PLCs.

![[Pasted image 20240903205457.png]]("https://blog.spookysec.net/img/Pasted image 20240903205457.png")

### Modeling Trains 3
We're onto the final question! This time a report has come through that an Engineering workstation is unable to communicate with the stations Historian server. 

My initial thought and reaction to this is it's likely a dual homing issue, so let's take a look at the Historian Servers and see their NICs. We can click on each Historian server, click on Interfaces and be shown all the NICs on the server.

![[Pasted image 20240903210247.png]]("https://blog.spookysec.net/img/Pasted image 20240903210247.png")

In addition, I'm going bring up all of the Workstations to see if there's any mismatch in any of the subnets, but essentially what we're looking for here is a Historian server that's third octet does not match the station number.

![[Pasted image 20240903210309.png]]("https://blog.spookysec.net/img/Pasted image 20240903210309.png")

After a few searches, we ID'd **Station 14**'s Historian server is in a mismatched subnet - it's in .113 when it should be in .114.

![[Pasted image 20240903210452.png]]("https://blog.spookysec.net/img/Pasted image 20240903210452.png")

### Closing Thoughts
This brings us to the end of the Anville Modeling Trains category, it's a nice & easy little set of challenges that showcase NetBox. It's a nice little asset inventory management, a good choice for this challenge. I'd like to have seen a little bit more flexibility in the searching functionality, as I found myself to be clicking around a lot in the challenge - but it's definitely a nice little tool.

~ Ronnie