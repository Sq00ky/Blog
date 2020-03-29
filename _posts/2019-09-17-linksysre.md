---
layout: post
title: Linksys EA6100 Firmware Reverse Engineering
subtitle: Ever wondered how your router works?
gh-badge:
  - star
  - fork
  - follow
tags:
  - Reverse Engineering
  - Routing
  - Linux
  - Kali
comments: true
published: true
date: '2019-09-17'
---
Have you ever wondered how your router works?
Well, I for one have. ISP and WAN technologies are super interesting, we'll take a look at Modem images later though :)

## Getting Started
We need two things to get started:
- Kali (My personal preference. You can use whatever distro you like, however, it may not have all the required tools)
- [Linksys EA6100 Router Firmware](https://www.linksys.com/us/support-article?articleNum=148444) (Version 1.1.5) 

Once you have that downloaded and your Kali environment setup, prepare a Workspace! It's going to get messy very quickly.

## Decompiling the image

Once you have a workspace your happy with, it's time to use a tool called ``binwalk``.
Binwalk is a tool written in Python that searches for the "Magic Byte", or the first roughly 8 bytes that identify a given file. This can be useful for bin,img, and other files that may contain a collection of files, similar to a zip archieve, but not normally extractable. To extract it, we can use this:

```
binwalk -e FW_EA6100_1.15.img

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             uImage header, header size: 64 bytes, header CRC: 0xEAD12788, created: 2016-04-29 23:24:21, image size: 1765596 bytes, Data Address: 0x80000000, Entry Point: 0x8000C2F0, data CRC: 0x4DA9E76D, OS: Linux, CPU: MIPS, image type: OS Kernel Image, compression type: lzma, image name: "Linksys EA6100 Router"
64            0x40            LZMA compressed data, properties: 0x5D, dictionary size: 33554432 bytes, uncompressed size: 5435184 bytes
1835008       0x1C0000        JFFS2 filesystem, little endian
```

Reviewing the results, we get multiple files, the JFFS2 being the most interesting. We may re-visit the uImage header at a later date, but for now, we're going to focus on the JFFS2 Filesystem.
To take a peak inside the file we're going to need to mount it. However, JFFS2 isn't a standard filesystem, so we're going to need to do a couple of things to mount it. This is what I have come up with to be a fairly consise guide step by step guide to mounting the JFFS2 File System. If it is *not* in Little Endian format (which this image is), you may need to convert it with a tool called jffs2dump. Like I said before, JFFS2 is already in the Little Endian format. So now, to mount the Firmware image! 

```
#Step 1 
#If /dev/mtdblock0 exists, remove file/directory and re-create the block device
rm -rf /dev/mtdblock0
mknod /dev/mtdblock0 b 31 0

#Step 2
#Create a location for the jffs2 filesysystem to
mkdir /mnt/jffs2_file/

#Step 3
#Load required kernel modules
modprobe jffs2
modprobe mtdram
modprobe mtdblock

#Step 4
#Write image to /dev/mtdblock0
dd if=root/workspace/FW/decompiled/1C0000.jffs2 of=/dev/mtdblock0

#Step 5
#Mount file system to folder location
mount -t jffs2 /dev/mtdblock0 /mnt/jffs2_file/

#Finally
cd /mnt/jffs2_file/
```
If you made it this far without errors, congratulations! You're almost done!
We can finally take a peak at the Filesystem!

```
root@MrSinister:~# cd /mnt/jffs2_file/
root@MrSinister:/mnt/jffs2_file# ls
bin  dev  etc  home  JNAP  lib  libexec  linuxrc  mnt  opt  proc  root  sbin  sys  tmp  usr  var  www 
```

On the surface, it looks like a standard Linux filesystem, that's because it is! A router honestly just runs Linux on it, you can dump the filesystem, view it, do whatever you like!
I plan on trying to work on implementing a backdoor on the device so I can gain persistant access to it. I have some ideas, but am not sure if I can successfully execute it yet. I encourage everyone to try this project with this firmware (or a similar/your own router's firmware). If you go and try this on your own, good luck!
