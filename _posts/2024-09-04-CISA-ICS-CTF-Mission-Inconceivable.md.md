---
layout: post
title: 2024 CISA ICS CTF - Mission Inconceivable
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
Onto the next challenge category in the CISA ICS CTF - Virbank City. This time we're going to be taking a look at the Mission Inconceivable challenge set. There was a ton to learn from this one, so I'm excited to take a shot at this one next.

This CTF has some infrastructure setup for the players to use; [Malcolm](https://github.com/cisagov/Malcolm), [Arkime](https://arkime.com/), [NetBox](https://github.com/netbox-community/netbox) and [CyberChef](https://github.com/gchq/CyberChef). Some of these services we'll be using in this challenge, some won't. I'll probably put this brief little introduction in each post so we're all on the same page. Anyways, onto the challenges!

![[Pasted image 20240903224828.png]](https://blog.spookysec.net/img/Pasted image 20240903224828.png)

###  Mission: Inconceivable 1
Virbank Medical was hit in a ransomware attack - or that's how it seems. The hackers were demanding something *interesting* not money, no. Something else... Tacos! The task here is to identify the name of the city/town that the hackers are in.

![[ransom_note (2).jpg]](https://blog.spookysec.net/img/ransom_note (2).jpg)

Right off the bat, I noticed something peculiar about this picture. There's a pen from a California based hotel and spa. Now, truth be told, I didn't read the question as well as I should have... There was a bold disclaimer stating **Note: It has nothing to do with the pen found in this image** :,) oh.

Well, that's neat. What else can we gather. Better Homes and Gardens in the background, Charles Schwab, barcodes, sunglasses, and mail. Well, mail is always an interesting one. I'm sure you've probably noticed this marking before on some mail you've received. 

![[Pasted image 20240903225510.png]](https://blog.spookysec.net/img/Pasted image 20240903225510.png)

Well, as it turns out, this can be used to trace the originating location of the mail. This is a barcode called the "Intelligent Mail Barcode". I tried to look up an OCR tool to expedite the process, but ultimately, I couldn't find one. This is honestly probably just a skill issue, but I knew what I had to do once I saw it. Armed with this online utility from [USPS](https://postalpro.usps.com/ppro-tools/encoder-decoder), I was on a quest. Each bar represents a "key". This key is used to translate into a code, which they then parse into a location. Magic.

| Key | Icon                                 | Description    |
| --- | ------------------------------------ | -------------- |
| F   | ![[Pasted image 20240903225605.png]](https://blog.spookysec.net/img/Pasted image 20240903225605.png) | Full Bar       |
| D   | ![[Pasted image 20240903225611.png]](https://blog.spookysec.net/img/Pasted image 20240903225611.png) | Descending Bar |
| A   | ![[Pasted image 20240903225616.png]](https://blog.spookysec.net/img/Pasted image 20240903225616.png) | Ascending Bar  |
| T   | ![[Pasted image 20240903225621.png]](https://blog.spookysec.net/img/Pasted image 20240903225621.png) | Track Bar      |
So, let's practice, the first set is. DAFFFDDFTTF. One descending, one ascending, three full bars, two descending, one full, two tracks and one full. Eventually, the whole thing will be decoded and we'll be left with the following answer:
![[Pasted image 20240903225956.png]](https://blog.spookysec.net/img/Pasted image 20240903225956.png)
**82336**. This is a ZIP code that belongs to **Wamsutter, Wyoming**. Definitely the middle of nowhere. 

### Mission: Inconceivable 2
Next, we need to narrow the location down even more. Using classic OSINT tactics, we need to use WiGLE (as directed) to identify any suspicious location where the attacker may be hiding out. The initial reaction is maybe their SSID has something to do with Tacos?

![[Pasted image 20240903230400.png]](https://blog.spookysec.net/img/Pasted image 20240903230400.png)

Surprise... That's exactly it :D The BSSID is **8A:9C:67:46:08:B1**

### Mission: Inconceivable 3
Now, through the power of magic, we've identified a list of shared coordinates in [Google Maps](https://www.google.com/maps/@/data=!3m1!4b1!4m3!11m2!2srquwm73MRvOKIZE9Yna-2g!3e3?entry=tts) that are numbered 1-9. Looking at the locations themselves, there's nothing that really stands out about them - they're all located in Australia, but there's nothing that spells out any sort of flag. Maybe the name of the locations? Ehh. Nothing really lines up well. 

But you know what does? Switching to Satellite view. Doing so gives us a different perspective. 

![[Pasted image 20240903230735.png]](https://blog.spookysec.net/img/Pasted image 20240903230735.png)

![[Pasted image 20240903230747.png]](https://blog.spookysec.net/img/Pasted image 20240903230747.png)

![[Pasted image 20240903230754.png]](https://blog.spookysec.net/img/Pasted image 20240903230754.png)
![[Pasted image 20240903230803.png]](https://blog.spookysec.net/img/Pasted image 20240903230803.png)

![[Pasted image 20240903230812.png]](https://blog.spookysec.net/img/Pasted image 20240903230812.png)
![[Pasted image 20240903230813.png]](https://blog.spookysec.net/img/Pasted image 20240903230813.png)

![[Pasted image 20240903230821.png]](https://blog.spookysec.net/img/Pasted image 20240903230821.png)
![[Pasted image 20240903230828.png]](https://blog.spookysec.net/img/Pasted image 20240903230828.png)
![[Pasted image 20240903230836.png]](https://blog.spookysec.net/img/Pasted image 20240903230836.png)

**noburrito**! Now *that* sounds like a flag to me!

### Mission: Inconceivable 4
Now, the last question wasn't as fun - they kinda threw it in there as a curve ball. The question is essentially "What is the property value of [this location](https://www.google.com/maps/place/37%C2%B020'05.6%22N+122%C2%B000'33.1%22W/@37.334875,159.943939,12417357m/data=!3m1!1e3!4m8!1m3!11m2!2srquwm73MRvOKIZE9Yna-2g!3e3!3m3!8m2!3d37.334875!4d-122.009186?entry=ttu&g_ep=EgoyMDI0MDgyOC4wIKXMDSoASAFQAw%3D%3D) in 2022?". This location is One Apple Park Way, Cupertino, California.

You can solve this one pretty easily by searching for [property tax records](https://gis.cupertino.org/propertyinfo/) and going back to 2022 where the appraised value of the land is listed for some obnoxious amount of money.

![[Pasted image 20240903231158.png]](https://blog.spookysec.net/img/Pasted image 20240903231158.png)

About $354,182,317 was the right answer, I believe. Like I said, some obnoxious amount of money. I just kinda rolled my eyes on this one.

### Closing Thoughts
This was a fun one because it taught me something new about Intelligent Mail Barcodes - not something you get to do, or even think about every day. It's pretty cool that USPS has this on their site. Chal 4 felt super out of place and kind of unnecessary, but none the less, I enjoyed the rest of them. 
