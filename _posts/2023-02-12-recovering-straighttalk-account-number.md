---

layout: post

title: Recovering Your Straight Talk Account Number

gh-badge:

- star

- fork

- follow

tags:

- Telecomm

- Cyber Security

comments: true

published: true

date: '2023-02-12'

---

Hello friends!
New year - new blog post. It's been a while, so I'm struggling to put some words onto paper, so I'll just start with what happened. 

Around 2~ months ago I was looking to transfer my phone number out of Straight Talk to another carrier, if you've never dealt with Straight Talk's support before, it's horrendous. They claim they cannot do things they can most certainly do all the time. For example, reactivating a recently deactivated SIM card, recovering account numbers (the focus of today's blog post), activating a new SIM card on a phone that is quote Not Supported quote that you are calling them from, etc.

They're just downright horrid. I've had my fair share of nightmares and issues with them over the years, so I decided to make the switch to a new carrier. There was only one *major-ish* problem. Anyways - To transfer your number out you need some key information

### Things needed to Transfer a Phone Number

You need to know a couple key pieces of information to transfer your number out, this is normally:
- A one-time transfer pin (Randomly generated)
- The original zip code you registered/activated your plan at (You should definitely know this)
- Your Account number (You probably don't know this, but it's your IMEI of your phone. Well, it should be...)

If you're like me and have had an account for 5+ years, you'd probably have gone through a handful of cellphones. I think I went through 3-4 throughout my time with Straight Talk. I have a horrible habbit of getting a new phone every so often because $reasons. Though on I almost always had issues registering and or activating my new phone with them. Because of this, some added complexities were added to my transfer process. It's not uncommon that people loose their account number and Straight Talk claims there is **no way to recover it**. 

Which is very disheartening as someone who's phone number is basically tied to their whole entire digital life. We use it for SMS-based OTP, recoveries, etc. It can be a pain to track down every service that has your phone number and make sure you change it. Well, the good news is that this is not true. It is completely possible to recover a lost account number and I'll show you how.

### 1. Acquiring the Last Four of your Account Number
The first thing you can do to make this search easier is find the last four digits of your account number. You can do this by texting ``FOUR`` to ``611611``.
![[https://blog.spookysec.net/img/sc.png]]

If this is done correctly, you should recieve a message that tells you the last four of your IMEI/SIM. Let's pretend mine are 6161. You should check this against your current IMEI/SIM to make sure the numbers are indeed not the same. For the most part, you can pop out your SIM card and read the numbers, or go into your phone settings and search for IMEI and SIM. They should be in there someplace. If the numbers don't match - continue to follow along.

### 2. Verifying It's not in Manage Lines
There's one more quick place you can check, which is under the "[Manage Lines](https://www.straighttalk.com/my-account/manage-lines)" page. Make sure the last four don't match any "Lines" associated with your account.

![[https://blog.spookysec.net/img/Pasted image 20230212181933.png]]

As you can see, there are no IMEIs/SIM card numbers ending in 6161. So let's continue.

### 3. Inspecting HTTP Traffic to Recover your Account Number
One of the most wonderful things about Web Applications is that they know things and can keep some things hidden from you that your browser may not render, but is definitely useful to you. How can we see the data that the server is sending to our Web Browser? Well, short answer, it depends. Ctrl+Shift+i is a common hotkey used to open up the "Inspect Element" portion of your Web Browser, what you've likely never noticed before is that there is a tab in there called "Networking". I've highlighted it in yellow on the screenshot below.

![[https://blog.spookysec.net/img/Pasted image 20230212182511.png]]

This will show you all the resources that go into rendering the web page in front of you - This includes the stuff you see and the stuff you don't see. For example, if we wanted to grab an image (let's say the websites Icon), this would have a copy of it for us! 

![[https://blog.spookysec.net/img/Pasted image 20230212182657.png]]

We can take this same exact prinicpal and apply it to Straight Talk's website - More specifically, your account dashboard. Login to Straight Talk's website if you haven't already, open up the Browser Dev Tools window with Ctrl+Shift+i, head over to Networking and browse to your Account Dashboard. 

![[https://blog.spookysec.net/img/Pasted image 20230212182907.png]]

If successful, you should see approximately 400~ requests to and from the Server. If you don't, give the page a refresh with Ctrl+Shift+R and make sure the dev tools window is still open and that you're on the "Networking" tab. Next, make sure you're focused in on the Dev tools section and press "Ctrl+F" to search all of the Web Requests, then punch in the last four that you recieved from ``611611``. 

![[https://blog.spookysec.net/img/Pasted image 20230212183142.png]]

As you can see below, there are 3 hits - You want to select the one from the Tracfone API that says "Profile". (https://webapigateway.tracfone.com/api/pub/customer-mgmt/customer/YOURCUSTOMERNUMBER/profile) Make sure that "Response is selected", Click on the window, press Ctrl+A and Ctrl+C to copy all the data in the window.
![[https://blog.spookysec.net/img/Pasted image 20230212183321.png]]

After it is selected, head over to a JSON Beautifier website such as "[Cyberchef](https://gchq.github.io/CyberChef/#recipe=JSON_Beautify('%20%20%20%20',false,true))", or if you're not comfortable pasting this data into a website, just paste it into Notepad on your computer. As long as you have an easier way to view the data, it doesn't matter!

![[https://blog.spookysec.net/img/Pasted image 20230212183818.png]]

You can either manually search for the number, or you can press CTRL+F and search for the last four and you should have found it, or at least I did. After this, I called up Straight Talk, spoke with a representative and asked if they could verify the Account Number I found here, They confirmed that the number I provided was indeed my account number and I began the port-out process. 

Anyways... I hope this helps someone out there who's had a bad experience with Straight Talk
~ Ronnie
