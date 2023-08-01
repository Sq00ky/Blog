---

layout: post

title: Programming with Impacket - Working with SMB

gh-badge:

- star

- fork

- follow

tags:

- Windows

- Impacket

- Cyber Security

- Python

comments: true

published: true

date: '2023-08-01'

---

[Impacket](https://github.com/fortra/impacket) by Fortra (formerly SecureAuth Corp) is probably best known for it's example scripts, they're a really awesome set of tools that allow you to do a **ton** of things. This can be as complex as Kerberoasting/ASREP-Roasting using GetUserSPNs\.py/GetNPUsers\.py or as simple as checking if a host is alive with ping.py. 

Lots of people often forget that Impacket, in addition to all of the example scripts provided within is a full fledge library for interacting with and manipulating protocols typically used within a Windows environment. So, where is this blog post going? Well, as the title of the post suggests, we're going to be programming with the Impacket Library today! 

This posts aims to get you some exposure to the Library, how to use the code in the example scripts to build your own and develop your own toolkit. Today we'll be working with and rebuilding some of the functionality that exists within smbclient.py as its the codebase I'm the most familiar with.

### Installing Impacket
In case this is your first time using Impacket, we're going to cover the installation process real quick. It's important to note that I am using Kali 2023.1, this process may differ slightly from operating system to operating system and version to version.

To start, we need to clone the repository from Github. We can do this with the following command:
```bash
git clone https://github.com/fortra/impacket.git /opt/impacket
```

This command will download Impacket into the /opt/impacket folder, after it's complete, you'll want to cd into /opt/impacket and execute python3 setup.py install. 

```bash
cd /opt/impacket/
python3 setup.py install
```

This will build and install Impacket and put it into your path. It's important to note that if you make any changes to the library itself (in /opt/impacket) you'll need to reinstall Impacket using the above command. After the install is finished we can move along!

### Sublime and You
[Sublime Text](https://www.sublimetext.com/) is my personal favorite text editor of choice, any IDE should have similar features as to what I'm going to demo. First, you'll want to select the file drop-down and select "Open Folder".
![[Pasted image 20230801133334.png]]

Navigate to /opt/, highlight "Impacket" and select "Open".
![[Pasted image 20230801133438.png]]

After, you should now see a list of files and folders on the left pane. As we navigate our way through the library, this will help keep us organized.
![[Pasted image 20230801133542.png]]

### Examples Scripts and the Library
Now that we have our workspace established, opened and created, we're now going to open up the examples dropdown and select smbclient.py - you should now have the source code of SMBClient.py open on your screen. If you do not have a untitled blank document that you can use for writing code, now would be a good time to create one. This can be done by selecting *Ctrl+N*, or by double clicking any of the "white space" in the same bar that holds all of the open files, or by selecting the + icon.
![[Pasted image 20230801134226.png]]
Once the new file is created, you can move the untitled tab to the left or right by holding left click and dragging it to the left or right. You can also drag it out of Sublime to create a new window entirely. If you hold "Control" and click, you can open multiple windows at once. This can be very helpful when you're writing code and reading the library to understand what it's doing.
![[Pasted image 20230801134513.png]]

So, here's generally where we should start structuring the program. Like most programs we're going to start with importing some libraries (Ex: ArgParse for ease of use) and grab some basic arguments, like Username, Password, IP Address, and Share. If you're unfamiliar with Argument Parsing, I recommend reading the [ArgParse documentation from Python.org](https://docs.python.org/3/library/argparse.html). We won't focus too much on it since this isn't the scope for this blog post. 

To understand what should happen next, reading the SMBClient.py source code can help out majorly. Somehow we have to authenticate to this server, so let's trace where the Username and Password get supplied at in SMBClient.py.

```python
37:     parser.add_argument('target', action='store', help='[[domain/]username[:password]@]<targetName or address>')
```

It appears that the username, domain, password and target are stored in the *target* variable. Let's search for any references to Target.

```python
76:     domain, username, password, address = parse_target(options.target)
```

We can see that it's split into their own independent variables in line 76. Now we can search for any of the arguments and we should be able to find it.

```python
97:    try:
98:        smbClient = SMBConnection(address, options.target_ip, sess_port=int(options.port))
99:        if options.k is True:
100:            smbClient.kerberosLogin(username, password, domain, lmhash, nthash, options.aesKey, options.dc_ip )
101:        else:
102:            smbClient.login(username, password, domain, lmhash, nthash)
103:
104:        shell = MiniImpacketShell(smbClient)
```
In line's 98-102 we actually have to connect to the host before we can authenticate to it. This is being handled by the SMBConnection function. Let's see if we can identify this in the source code of the Library to see what arguments can be supplied. By going back to the top of SMBClient.py, we can see all the imports. This will tell us where we need to look:

```python
29: from impacket.smbconnection import SMBConnection
```

We should be able to find this in the Impacket/smbconnection.py file. We can validate that this file exists in either Sublime or the terminal (I chose the terminal for funsies)

![[Pasted image 20230801184532.png]]

We can see that there is a SMB Connection class exists. This looks like what we're searching for. If we open the file up in Sublime, we can see that sure enough, SMBConnection is the first class declared within the file.

![[Pasted image 20230801184652.png]]

We can see that it takes in several arguments, these being the following:
- remoteName
- remoteHost
- myName
- sess_port
- timeout
- preferredDialect
- existingConnection
- manualNegotation

That's quite the list of arguments to supply to SMBConnection. Fortunately, not all of them are required and even have defaults, it's still nice to know that we have the ability to customize them if needed. There are even some interesting ones like existingConnection. Perhaps this is used in NTLMRelayx. 

Try the skills you learned in the previous section (analyzing the source code in the example script (NTLMRelayx.py) to find the library file that contains the relevant code) to see if you can identify what file is depicted below.

![[Pasted image 20230801185036.png]]

Back on track! Now that we know what argument the SMBConnection class expects, we can add our first real bit of code that uses Impacket. But first, don't forget to import the library! At a minimum, we must specify the remoteName and the remoteHost argument or else it may not connect properly. we can see some conditional if statements regarding the two very early on in the SMBConnection class.

![[Pasted image 20230801190226.png]]

**Code Checkpoint** - If you've made it this far in the post, that means it's time for a code checkpoint! Here's everything we have so far:
```python
#!/usr/bin/python3
import argparse
from impacket.smbconnection import SMBConnection

args = argparse.ArgumentParser(description="A basic tool for reading files off of SMB Shares", formatter_class=argparse.RawTextHelpFormatter, usage=argparse.SUPPRESS)

args.add_argument('-u', '--username', dest='username', required=True, default=None,help='Username to use for SMB connections.')
args.add_argument('-p', '--password', dest='password', required=True, default=None,help='Password to use for SMB connections.')
args.add_argument('-d', '--domain', dest='domain', required=True, default=None,help='Domain  to use for SMB connections.')
args.add_argument('-i', '--ipaddress', dest='ip', required=True, default=None,help='The IP Address or Hostname of the host to connect to.')
args.add_argument('-s', '--share', dest='share', required=True, default=None,help='The SMB Share you would like to connect to.')
args.add_argument('-f', '--file', dest='file', required=True, default=None,help='The file which you would like to read.')
args.add_argument('-v', '--verbose', dest='verbose', required=False, default=False, action=argparse.BooleanOptionalAction, help='This option will enable the program to be more or less verbose.')

args = args.parse_args()

if(args.verbose == True):
	print("[DEBUG] Domain: " + args.domain)
	print("[DEBUG] Username: " + args.username)
	print("[DEBUG] Password: " + args.password)
	print("[DEBUG] IP Address: " + args.ip)
	print("[DEBUG] Share: " + args.share)
	print("[DEBUG] File: " + args.file)
print("Connecting to  " + args.ip)

try:
	smbConn = SMBConnection(remoteName=args.ip, remoteHost=args.ip)
except Exception as e:
	print("Failed to connect to " + args.ip + "\nReason: " + str(e))
	exit(1)
```

We're going to continue expanding on this, if Python isn't your strong suit and you're having difficulties, use this! 

**Back to Programming** - Now we have to login to the server that we just established a connection to. Looking at the smbconnection.py file, on line 259 we have a login function.
![[Pasted image 20230801190912.png]]

It takes in the following arguments:
- Username
- Password
- Domain
- LM/NTLM hash
- NTLM Fallback

We're primarily concerned with Username, Password and Domain here. Let's add the login function. We must call the variable we assigned to the SMBConnection class (smbConn) and specify the function (smbConn.login) and supply the arguments. I highly recommend you continue to handle errors as it's very crucial to know when you've made a mistake in either entering the command, the servers down and cannot authenticate for some reason, or if there's a fault in the Library. Reason can vary, it is helpful none the less!
![[Pasted image 20230801191344.png]]

Next, we have to select the share we want to use. If we follow along in the SMBClient.py source code, we notice after authentication is handled/finished, it passes it over to MiniImpacketShell. We're not really down to re-use this as this is a programming exercise, so let's continue reading SMBConnection.py.

On line's 350-360, a function is created called "connectTree". If you've ever analyzed a SMB Packet Capture, this may stand out to you as a Tree Connect is what's used to connect to a share.
![[Pasted image 20230801191811.png]]

We can see that this function takes in only one argument - Share. Let's try invoking this function as well. 
![[Pasted image 20230801192018.png]]
**Code Checkpoint** - Progress is being made! Which means it's time for another code checkpoint. This is continuing from the line we left off on in the last Code Checkpoint. You should be able to copy and paste the code below:

```python
print("Authenticating to " + args.ip)
try:
	smbConn.login(user=args.username, password=args.password, domain=args.domain)
except Exception as e:
	print("Failed to authenticate to " + args.ip + "\nReason: " + str(e))
	exit(1)

print("Connecting to \\\\" + args.ip + "\\" + args.share)
try:
	smbConn.connectTree(share=args.share)
except Exception as e:
	print("Failed to connect to \\\\" + args.ip + "\\" + args.share + "\nReason: " + str(e))
	exit(1)
```

Alright, we're making good progress - Let's try to add in our file reading functionality now. Skipping down to line 754 in smbconnection.py, we can find the definition of the getFile function. This will be handy for reading files as it only takes in three arguments - a shareName, pathName and a "callBack".
![[Pasted image 20230801192734.png]]

Callback isn't exactly self explanatory, so it may be a good idea to read into MiniShell and see what it's doing. If you're lazy - I can give you a quick answer. It wants a byte stream that it can write the data out to. 

You have two methods here that you could use. You can write the data out to the disk, or you can write it to a memory stream. I recommend writing it out to disk because its slightly easier and I'm sure most people with an intermediate working level of python know how to do this already. If you have a more advanced knowledge set, or advanced use cases, you may want to write this into memory, do whatever is needed, then continue on with your day. Especially if you're not trying to save this data for a long time thing.

So, with all that said, we can create a file handle where we write our byte stream out to, invoke the getFile function from the SMBConnection class, specify the share and the file path, then lastly specify the callback to write the data onto disk. After that operation is finished, we can close the file handle, and open it with a read only flag, then print all the data to the user.

**Code Checkpoint** - This operation sounds fairly complex but is really straight forward. The addition of the file stream is what makes it a bit more complicated.
```python
print("Downloading File...")
try:
	fh = open("temp.txt","wb")
	smbConn.getFile(shareName=args.share, pathName=args.file, callback=fh.write)
except Exception as e:
	print("Failed to download file: " + str(e))
	fh.close()
	exit(1)
fh.close()
print("Reading file:\n\n")
fh = open("temp.txt", "r")
print(fh.read())
```

### Wrapping up & Testing

So, for my example, I want to read the /etc/hosts file on Windows. For those of you who don't know, it's stored in C:\\Windows\\System32\\Drivers\\etc\\hosts. This should be accessible from the C$ share. So, if we run the command with these arguments, we should get the contents of the file:
```bash
python3 smbFileRead.py -u Administrator -p 'SuperSecretAdminPassword1337!' -d contoso.com -i dc.contoso.com -s C$ -f /Windows/System32/Drivers/etc/hosts 
```

If we wrote the code correctly, we should receive the contents of /etc/hosts back. And giving it our final test...
![[Pasted image 20230801194837.png]]

We received the contents back! Looking at the file on the Windows side, we can see we have the same results:
![[Pasted image 20230801194910.png]]

So that's about it. That's how you can build your own file reading utility with Impacket. I know it's a bit different from my standard blog posts, I don't really do much programming, but I thought this might make for an interesting topic. You can find the source code [here](https://github.com/Sq00ky/Blog/blob/master/smbFileRead.py). Feel free to hit me up on [X](https://twitter.com/NaisuBanana) if you're having any issues, I'd be happy to try to help out!

As always, thanks for reading. I hope to see you all soon :)