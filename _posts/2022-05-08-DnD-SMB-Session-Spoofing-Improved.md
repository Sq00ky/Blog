---

layout: post

title: Deception in Depth - Spoofing SMB User Sessions Improved

gh-badge:

- star

- fork

- follow

tags:

- Windows

- Cyber Security

- Deception

comments: true

published: true

date: '2022-05-08'

---

Hello Everyone!

It's been a while since I have been able to do some research on deception related topics. Over this weekend I was able to spend about a day researching a topic that I had done before - Spoofing in logged in users.

The last time I explored this topic, I had come up with a method to spoof logged in users by abusing S4U user impersonation in Constrained Delegation. This original method is impractical because it involves opening up an attack path between two workstations. It also provides an indicator that there may be deception activities occuring within your network. 

So how could I improve this method? Well, ideally we drop Constrained Delegation being a requirement which would massively improve this method. Especially since you do not have to explain to your AD Admins the type of work you're doing. Lastly, we can try to remove the fact that we need two devices to pull this off. 

This actually sounds a lot more difficult than it actually is. Before we dive into this, we need an environment to play in.

### Lab Setup
So here's what my lab looks like. We the following devices in place:
- One Domain Controller
- One Server
- Three Workstations

We have a handful user accounts in the environment:
- One Domain Administrator
	- svc-admin
- One Service Account
	- svc-pcjoiner
- Three User Accounts
	- Jack, Eric, and Jill
- Two Server User Accounts
	- su-emily, and su-jared
- Two Workstation Admin Accounts
	- wadm-tom, wadm-morgan

We have several Group Policy Objects in place:
- Server Users cannot sign into Workstations
- Domain Admins cannot sign into Workstations or Servers
- User Accounts cannot sign into Servers and Domain Controllers
- Workstation Admins cannot sign into Servers and Domain Controllers

This effectively sets up tiering in the environment. Pretend there is an adversary in our environment for a minute, they will only be able to move inbetween workstation infrastructure and will not be able to compromise server or domain controller infrastructure without *exploiting* a vulnerability. 

An adversary doesn't know this going into the environment, we're going to play on that - We will simulate a privileged user signed into one of the Workstations - Lab-Wkst-2. Lab-Wkst-2 serves no legitimate purpose within the environment, and we identify a user signing into that workstation, we can safely assume there is an instrusion in the environment. 

And that is what our environment and stage looks like for our lab. This is fairly close to what a production environment should look like, so you can implement it in your job if you're interested :)

### The Research
On 5/7 I began researching how the SMB protocol works, how sessions are created and stored and came with no easy way to inject or fake SMB sessions. How unfortunate. The only way I had come up with is creating a named pipe, but I wasn't sure how I could log a user session in the named pipe without revealing real credentials without reverse engineering protocols that are far beyond my skill level. For reference - I did try reverse engineering *net use* and it didn't go over to well lol.

Something I did remember is that there is one Windows API (CreateProcessWithLogonW) that you can use to create processes without verifying the credentials against Active Directory. How interesting. I wonder if we could use to execute the *net use* command against a share on our local computer.

The answer to that is yes - we can totally do this. So the neat thing about CreateProcessWithLogonW is *if* the credentials supplied are invalid (with the NETLOGON_ONLY flag) it reverts back to the token of the parent process, meaning if we want to query a share against the local computer (to simulate an SMB session), we don't need valid credentials because we have a privileged process token! Perfect.

Knowing this information, we can write a program that invokes the CreateProcessWithLogonW Windows API with a real Domain Admins username, the real domain and no password and call the *net use \\LOCALHOST\c$* command to create a fake user session. The only caveat is that this must be ran as an Administrator, which is no big deal, we can convert this to a service that runs in the background.

### The Code
The actual code behind this is incredibly simple - here it is:
```c++
#include <Windows.h>
#include <tchar.h>
#include <strsafe.h>

using namespace std;
int main(){
while (TRUE){
		STARTUPINFO si;
		PROCESS_INFORMATION pi;

		si.wShowWindow = 0;
		si.dwFlags = 0x00000001;

		wchar_t cmdLine[] = L"'C:\\Windows\\System32\\net.exe' use \\\\localhost\\c$";

		CreateProcessWithLogonW(L"svc-admin", L"contoso.com", NULL, LOGON_NETCREDENTIALS_ONLY, L"C:\\Windows\\System32\\net.exe", cmdLine, NULL, NULL, NULL, &si, &pi);
	}
}
```

I'll be honest - I don't really know how to explain this program, since I have already explained it. It's relatively straight forward, but here it is:
- Lines 7-8 create two structs, si and pi (StartupInfo and Process_Information)
- Lines 10-11 modify properties within the struct hide the window for the newly spawned process
- Line 13 has the command line paramater that is invoked (net use \\localhost\C$)
- Line 15 calls the Windows API itself and invokes our fake session

Pretty simple, I think. I'm not going to explain the [process of creating a service](https://docs.microsoft.com/en-us/windows/win32/services/the-complete-service-sample) because Microsoft can do it far better than I can :) 

### Testing SMB Session Spoofing
Now, the most important part - Testing. I spent around 3-4 hours tweaking the code, testing, and troubleshooting, so this part was both incredibly exciting and frusturating. I wont talk too much about it since it was small modifications here and there. I'd like to give a shoutout to a couple of tools that made this process so much eaiser:

- [API Monitor](http://www.rohitab.com/apimonitor)
- [Process Explorer](https://docs.microsoft.com/en-us/sysinternals/downloads/process-explorer)

The two tools (API Monitor more than Process Explorer) were incredibly helpful in troubleshooting and diagnosing issues. That's all I'll say for now on troubleshooting :)

So how are we going to test that this has worked? Good question! There's two ways:
1. Running the ``net sessions`` command as an Administrator
2. Running Sharphound and collecting session information

**Verifying with Net Sessions**
This is relatively trivial, in order to view active sessions on a computer, you need to be a local administrator on the system. This isn't 100% true as the Windows APIs that the net session command uses do not require you to have this, but one parameter that is set does.

I have converted the program to a service for ease of use, we can see the service "Inject" is running and we have a spoofed user session!

![[Pasted image 20220508185651.png]](https://blog.spookysec.net/img/Pasted image 20220508185651.png)

It's important to note that this session lasts approximately 15 minutes. The service is set to refresh the session every 12.5 minutes to prevent any visability gaps. 

![[Pasted image 20220508190149.png]](https://blog.spookysec.net/img/Pasted image 20220508190149.png)

**Verifying with Bloodhound**
Verfiying that our session has successfully been created with Bloodhound is *almost* as easy as Net Sessions - First I'd like to cover *how* Bloodhound does session enumeration (I personally think this is important). [Walter Legowski](https://twitter.com/SadProcessor/) has put together an excellent diagram of how Sharphound does each component of enumeration on the system. 

![[Pasted image 20220508190622.png]](https://blog.spookysec.net/img/Pasted image 20220508190622.png)

The component we're interested in is Session, we can see that Bloodhound does this over TCP/445 (SMB/RPC) and uses the [NetSessionEnum](https://docs.microsoft.com/en-us/windows/win32/api/lmshare/nf-lmshare-netsessionenum) and [NetWkStaUserEnum](https://docs.microsoft.com/en-us/windows/win32/api/lmwksta/nf-lmwksta-netwkstauserenum) Windows APIs. In the bottom left, there are a few important notes:
* Sessions vs LoggedOn
	* LoggedOn is more accurate but requires Admin
	* Session requires Admin on Server 2016/Windows 10 v1607 or higher

In order to enumerate sessions, the domain user must be an Admin on the device they're enumerating. I have created a seperate Domain Administrator account called svc-session that does not follow the normal tiered account access restrictions to perform enumeration from. The two commands we're interested in running is the following:
- sharphound.exe -c all
- sharphound.exe -c session,loggedon

![[Pasted image 20220508200245.png]](https://blog.spookysec.net/img/Pasted image 20220508200245.png)

Afterwards, we will be left with two zip files that we will load into BloodHound. After loading the files, we can look for user sessions and we can see that svc-adm has a session on dc.contoso.com and lab-wkst-2.contoso.com. We have successfully decieved the hound!

![[Pasted image 20220508200413.png]](https://blog.spookysec.net/img/Pasted image 20220508200413.png)

### Implementation in Production
So, how can you implemenet this in your production environment? After all, we have a neat little tool that can lure Red Teamers, Penetration Testers and APTs...

It's actually easier than you're probably thinking - The full service code is avalible for download on [Github](https://github.com/Sq00ky/SMB-Session-Spoofing).  You'll need to modify the Username and Domain name parameters in the CreateProcessWithLogonW Windows API and compile the code in Visual Studio. 

Once that is done, you'll need to deploy the binary on an endpoint. Ideally, this should be in a less known or hidden location, C:\Windows\ and C:\ProgramData\ are fairly good options. Once you have your location selected, we need to create the service. You can do so with the following command:
```
sc create servicename binpath="C:\your\binary\path\service.exe" start="auto"
```

After this is setup, you're ready to move into the testing phase. Once you have verified that this works properly, we're then ready to move into the monitoring phase.  This highly depends on what tools you have avalible to you - so I won't give any advice other than ensure you have tested your monitoring solution. The last thing you want is for the device to get compromised and you not knowing!

Anyways - I hope you learned something and helped inspire you to go out and do something :) 

See you all next time!
~ Ronnie
