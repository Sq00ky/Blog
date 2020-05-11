---
layout: post
title: Decrypting TACACS+ Traffic in Wireshark
gh-badge:
  - star
  - fork
  - follow
tags:
 - Wireshark 
 - Analysis
 - TACACS
 - TFTP
 - Introduction
comments: true
published: true
date: '2020-05-11'
---

Being able to intepret traffic in Wireshark is an incredibly important part in being a Cyber Security Analyst. Today we're going to take a look at how to interpret TFTP and TACACS+ traffic and decode the contents of TACACS+ encrypted packet.

### Inspecting TFTP Traffic

TFTP is a protocol that is used to transfer files from one device to another in a non-secure, connectionless fashion. TFTP runs over UDP port 69, which means that if a packet is sent and it does not reach the end device, it will not be re-transmitted. Alternatively, if there is noise on the wire, it will be shown As seen here:

![eb781356ac760d67a7133b78f6dc4fe4.png](https://blog.spookysec.net/img/eb781356ac760d67a7133b78f6dc4fe4.png)

In order to inspect UDP traffic, you must open the Packet Capture in Wireshark, find the traffic you'd like to inspect, right click and hit "Follow UDP Stream".

![90dc2c38f9ded882f6639def690ffe74.png](https://blog.spookysec.net/img/90dc2c38f9ded882f6639def690ffe74.png)

A new window will be displayed to you showing the data contained within the UDP stream.

![b92216aacd16bd8d9d708db75abdc204.png](https://blog.spookysec.net/img/b92216aacd16bd8d9d708db75abdc204.png)

Beautiful, now we can see that over TFTP the contents of "show run" from a Cisco device was transmitted. Knowing this, we may be able to decrypt some passwords that are stored using reversable encryption (ex. Type 7 Passwords).

```
Current configuration : 1576 bytes
!
version 12.4
service timestamps debug datetime msec
service timestamps log datetime msec
service password-encryption
!
hostname R1
!
boot-start-marker
boot-end-marker
!
enable secret 5 $1$cPBj$qwX7keZqu6vF1UqNZxgCU0
!
aaa new-model
!
aaa authentication login default group tacacs+ enable
aaa authentication login no_auth none
aaa authorization config-commands
aaa authorization exec default group tacacs+ none
aaa authorization commands 1 default group tacacs+ none
aaa a........uthorization commands 15 default group tacacs+ none
!
aaa session-id common
memory-size iomem 5
no ip icmp rate-limit unreachable
!
ip cef
no ip domain lookup
ip domain name local.lan
!
ip auth-proxy max-nodata-conns 3
ip admission max-nodata-conns 3
!
username cisco password 7 05080F1C2243
!
ip tcp synwait-time 5
ip ssh time-out 60
ip ssh logging events
ip ssh version 2
!
interface Loopback0
 ip address 172.16.1.1 255.255.255.255
!
interface FastEthernet0/0
 ip add........ress 192.168.1.1 255.255.255.0
 duplex auto
 speed auto
!
interface FastEthernet0/1
 ip address 10.1.1.1 255.255.255.0
 duplex auto
 speed auto
!
no ip http server
no ip http secure-server
ip forward-protocol nd
!
ip tacacs source-interface FastEthernet0/0
!
no cdp log mismatch duplex
!
tacacs-server host 192.168.1.100 key 7 0325612F2835701E1D5D3F2033
!
control-plane
!
line con 0
 exec-timeout 0 0
 privilege level 15
 logging synchronous
 login authentication no_auth
line aux 0
 exec-tim........eout 0 0
 privilege level 15
 logging synchronous
line vty 5 15
!
end
```

Inspecting the contents of the extracted UDP stream there are several Type 7 passwords which we can potentially use. One used to remotely access the device, and the other appears to be a TACACS+ password.

```
username cisco password 7 05080F1C2243
tacacs-server host 192.168.1.100 key 7 0325612F2835701E1D5D3F2033
```

Using this [online tool](https://www.ifm.net.nz/cookbooks/passwordcracker.html) we can reveal the cleartext passwords. After decoding the passwords we have:

```
username cisco password 7 cisco
tacacs-server host 192.168.1.100 key 7 AZDNZ1234FED
```

### Inspecting TACACS+ Traffic

When I did this challenge, I had a difficult time finding resources on how to decrypt TACACS+ traffic, but it's a lot easier than I expected. All you'll need is the key we found in the TFTP traffic and Wireshark. First, you'll need to go to:
Edit -> Preferences -> Protocols -> TACACS+

![029b1ef8142814ea372ba714e9bb79c2.png](https://blog.spookysec.net/img/029b1ef8142814ea372ba714e9bb79c2.png)

We will be able to enter the encryption key used to encrypt the TACACS+ traffic which we can use to decrypt it. Once entered, click "Ok", and then locate the TACACS+ traffic stream.

![95a7826fe99c5d7394e1b79e2c4c2159.png](https://blog.spookysec.net/img/95a7826fe99c5d7394e1b79e2c4c2159.png)

If you look towards the bottom, you'll notice an additional section added next to "Frame", called TACACS+ Decrypted. This is incredibly easy to miss, but it will allow us to view the decrypted contents of the TACACS+ packet.

![3409d083d2b9d4c772f584dcd3867cda.png](https://blog.spookysec.net/img/3409d083d2b9d4c772f584dcd3867cda.png)

Inspecting the Hex -> ASCII payload we can see the clear text conversation occuring:

```
shkCTF{T4c4c5_ch4ll3n63_br0}
```

And we can see we successfuly decrypted the TACACS+ contents to reveal the flag hidden inside.

### Credits:

Thank you to MrErne and Nofix from SharkyCTF for putting this challenge together.

Inspecting and reviewing traffic from Wireshark is an incredibly valuable skill that is absolutely necessary for anyone looking to go into a more Blue Team oriented role. Reviewing, inspecting, and determining if an attack occured is an incredibly important skill for anyone.

Thanks for reading my 1AM ramblings.
~Spooks
