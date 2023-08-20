---

layout: post

title: Deploying BloodHound Community Edition for Pentesters

gh-badge:

- star

- fork

- follow

tags:

- Windows

- BloodHound

- System Administration

comments: true

published: true

date: '2023-08-19'

---

Hello everyone! 

I know this post is a bit late, blame Blackhat/DEFCON, but I wanted to put a guide together for deploying BloodHound Community Edition for Pentesters and Red Teams. This is going to be more of an Administration guide than a "how to use cool new thing" - the core components of BHCE are the same as BloodHound Classic.

So, the reason for writing this post: I deployed BHCE at the company I work for and I ran into some things I've never had to do before, so I thought this might be a good topic to write a blog post on. So, here's all the topics we're going to cover today:
- Deploying BloodHound Community Edition
- Modifying the BloodHound Config File
- Creating User Accounts
- Setting up Multi-Factor Authentication
- Deploying SSL/TLS
- Backgrounding Docker

Note: *that some sections might be a little bit longer and exact steps may change from version to version. I'll try my best to keep this updated, but I generally don't update older blog posts*

### Deploying BloodHound Community Edition
Before we begin, some pre-requisites are required:
- A Linux Server 
- Network Access
- Docker/Docker-Compose
  
That's pretty much it! As long as you have those things, you should be able to get started. I'll be using Kali for the deployment, we can install Docker with the following command:
```
apt install docker-compose
```
This will install Docker-Compose, Docker, and all it's dependencies. Next, we'll want to pull down two files from the **SpecterOps BloodHound** repository, it can be found [here](https://github.com/SpecterOps/BloodHound). Be careful not to confuse it with the BloodHoundAD BloodHound repository. That repository will soon be archived and will no longer be supported. Anyways - continuing on. From the repo, we want to grab the following files:
- [Docker-Compose.yml](https://github.com/SpecterOps/BloodHound/blob/main/examples/docker-compose/bloodhound.config.json)
- [BloodHound.config.json](https://github.com/SpecterOps/BloodHound/blob/main/examples/docker-compose/bloodhound.config.json)

I recommend creating a new folder in ``/opt/`` called "BloodHound" to store these files, alternatively, you can just clone the whole repository and copy the BloodHound.config.file. This can be done with the following commands:
```bash
git clone https://github.com/SpecterOps/BloodHound.git /opt/BloodHound
cd /opt/BloodHound/
cp examples/docker-compose/* ./
```
For a single user, initial deployment this will suffice and give us everything we need. It doesn't really scale for multi-user deployments, however. We'll cover that in the Deploying SSL/TLS section though.

As stated before, for a single user initial deployment, this will give us everything we need. We can start BloodHound with the following command:
```bash
docker-compose up
```

This will then begin downloading the required containers from docker.io, please note this may take a few minutes.

![[Pasted image 20230819233649.png]](https://blog.spookysec.net/img/Pasted image 20230819233649.png)

The Deployment will be complete when you see an initial password displayed on the screen. This will be the password for the Administrator user account. 

![[Pasted image 20230819234338.png]](https://blog.spookysec.net/img/Pasted image 20230819234338.png)

You will now be able to login with the initial set password. 

![[Pasted image 20230819235407.png]](https://blog.spookysec.net/img/Pasted image 20230819235407.png)

Upon logging in, you will be prompted to change the default password. This password must meet a certain set of complexity requirements.

![[Pasted image 20230819235531.png]](https://blog.spookysec.net/img/Pasted image 20230819235531.png)
### Modifying the BloodHound and Docker Config Files

Something super important to note is this may expose you to potential attacks. Often BloodHound may be used on hostile networks like HackTheBox, TryHackMe, or another environment, so additional hardening steps may be a good idea. I'm going to run with this to show you a **basic** modification of the config files - later we'll deploy SSL/TLS.

If you are using this for you and you only, it may be worth modifying the config file to bind to 127.0.0.1 instead of 0.0.0.0. This can be done by modifying the Bloodhound.config.json file in /opt/BloodHound.

```json
{
  "version": 1,
  "bind_addr": "127.0.0.1:8080", 
  ...
    "last_name": "Admin",
    "email_address": "spam@example.com"
  }
}
```

We will also have to modify the Docker-Compose.yml file. Note that by default a config file is not specified. We want to uncomment these lines so our config file is used. 
![[Pasted image 20230819235200.png]](https://blog.spookysec.net/img/Pasted image 20230819235200.png)

After uncommenting the lines, we can restart the Docker container by pressing ctrl+c to kill the process. Afterwards, we can re-execute ``docker-compose up``, and the container will restart. 
![[Pasted image 20230820000230.png]](https://blog.spookysec.net/img/Pasted image 20230820000230.png)
Now, if an attacker tries to connect to our BloodHound instance, they will be unable to do so. Keep this in mind while working within hostile environments! For the blog post, we are going to assume you're working with a **team** and not in an individual setting, so we're going to revert this config back to 0.0.0.0:8080. 

```json
{
  "version": 1,
  "bind_addr": "0.0.0.0:8080",
...
    "last_name": "Admin",
    "email_address": "spam@example.com"
  }
}
```

### Creating User Accounts
As always, in a team setting it's bad practice to use the default Administrator user as your personal user account, so in this next section, we'll show you how to create a new user. We can do this by navigating to the settings cog, selecting "Administration", then "[Manage Users](http://localhost:8080/ui/administration/manage-users)".
![[Pasted image 20230820001244.png]](https://blog.spookysec.net/img/Pasted image 20230820001244.png)

By default, there will be one user, Admin with the email spam@example.com. If you want to modify this, you can select the "hamburger" menu and select "Update User".
![[Pasted image 20230820001330.png]](https://blog.spookysec.net/img/Pasted image 20230820001330.png)

Additionally, this is also modifiable in the BloodHound config file:
```json
...
  "collectors_base_path": "/etc/bloodhound/collectors",
  "default_admin": {
    "principal_name": "admin",
    "first_name": "Bloodhound",
    "last_name": "Admin",
    "email_address": "spam@example.com"
  } 
}
```

Back to the web application, selecting "Create User" will open a new dialogue box:
![[Pasted image 20230820001629.png]](https://blog.spookysec.net/img/Pasted image 20230820001629.png)

In here, we can assign one of four roles, Read Only, Upload Only, User and Administrator. Note that currently the User role does not have permission to upload files. This may be a misconfiguration, so for the time being, I would recommend having a dedicated user account to upload files as Administrator is **very** broad permission wise. For a single user deployment, Administrator should be fine, if you're working in a team, I would opt for a dedicated File Upload role. This process can be repeated for each member of the team. 

For awareness, it's possible to disable, force password changes, change passwords, generate API tokens, and delete user accounts as well.

![[Pasted image 20230820002428.png]](https://blog.spookysec.net/img/Pasted image 20230820002428.png)

### Setting up Multi-Factor Authentication
Continuing our hardening best practices, multi-factor authentication can be setup on per-user basis. Unfortunately, it does not look like there is a way to force MFA at this time, so it would be best to setup an internal policy that requires each user to have MFA configured due to BloodHound containing sensitive data.

MFA can be configured by navigating to the settings cog and then selecting "[My Profile](http://localhost:8080/ui/my-profile)".

![[Pasted image 20230820002731.png]](https://blog.spookysec.net/img/Pasted image 20230820002731.png)

You can then click the toggle button for MFA - You will be prompted to enter your current password.

![[Pasted image 20230820002804.png]](https://blog.spookysec.net/img/Pasted image 20230820002804.png)

You will then be prompted to scan a QR code for an authenticator app such as Authy, gAuth, RSA SecurID, Microsoft Authenticator, or another app.

![[Pasted image 20230820002839.png]](https://blog.spookysec.net/img/Pasted image 20230820002839.png)

If you input the code correctly, you should receive a prompt that says you'll need to use your Password and TOTP code. Navigating back to the "Manage Users" page, you'll see that the user is now flagged as having MFA enabled.

![[Pasted image 20230820003009.png]](https://blog.spookysec.net/img/Pasted image 20230820003009.png)

The next time you login, you'll be prompted to input your MFA token.
![[Pasted image 20230820003125.png]](https://blog.spookysec.net/img/Pasted image 20230820003125.png)

And that's it, that's the MFA setup. Super simple. If you need to disable MFA, you just need to go back to your profile and select the toggle button. It will require you to input your password again, and then MFA will be disabled. There does not currently appear to be a way to reset the MFA token, so if you lose your token it may be lost for good and you may have to delete/re-create the user account, so be careful!

### Deploying SSL/TLS
SSL/TLS is absolutely necessary in my opinion if you're working in a team - by default BHCE does **not** come with a self-signed certificate, it only runs on HTTP as you may have already noticed. This is a bad idea for a number of reasons, most importantly, you don't want someone to snoop on your password! So - how can we deploy HTTPS? 

Great question. I struggled with this for quite a bit since I had no prior experience with Docker. Generating SSL/TLS certs are fairly easy, most often this consists of submitting a request to your PKI team. You may have to do some OpenSSL magic to create a .cer and a .pem file. Make sure that your .pem file is **not** password protected. There are plenty of guides out there on how to extract various things from various formats. I'm going to use CloudFlare to create a SSL certificate for me. 

I recommend placing these files in a location other than /opt/BloodHound, though I'm going to put them there for the ease of use. We'll have to modify our config file to include our certs, like so.

```json
...
  "features": {
    "enable_auth": true
  },
  "tls": {
    "cert_file": "/opt/bloodhound/cert.cer",
    "key_file": "/opt/bloodhound/cert.pem"
  },
  "database": {
...
```

Now, if we try to start the application right now, we'll receive an error that says something like this:
```
bloodhound_1  | {"level":"error","time":"2023-08-20T04:50:35.429379169Z","message":"HTTP server listen error: open /opt/bloodhound/cert.cer: no such file or directory"}
bloodhound_1  | {"level":"error","time":"2023-08-20T04:50:35.429503069Z","message":"HTTP server listen error: open /opt/bloodhound/cert.cer: no such file or directory"}
```
This is because the files are **not** on the containers filesystem - only on the hosts. So, we must modify the Docker configuration file to share a mount point. We can do this by adding a line right below our specified configuration file; 
```
    volumes:
      - ./bloodhound.config.json:/bloodhound.config.json:ro
      - /opt/BloodHound/:/opt/bloodhound/:ro
```

This is going to share **all** the files in /opt/BloodHound to /opt/bloodhound on the docker container. So note that if you have **any** sensitive files in this directory, they can be accessible in this directory, individual files can be shared as well, which may be more preferable. Note in the above line we can specify this as Read Only which makes it *slightly* more secure.

Anyways - security rant concerns aside, after saving this file and putting the certificates in /opt/bloodhound/ and having them named cert.cer/cert.pem (or whatever you would like to name them), we can restart the server. Once again, this can be done by ctrl+c to stop the process and re-running ``docker-compose up``.  Now, you should see our site is served with an SSL certificate! Our communications between us and the site are now encrypted. Note that I'm using a self-signed SSL cert for our demo here. I'm not trying to make things overly complex, though you should use a signed/trusted certificate in production.

![[Pasted image 20230820010540.png]](https://blog.spookysec.net/img/Pasted image 20230820010540.png)
And that's it, we now have HTTPS!

While we're on the topic of best practices, there's a few things that I think are worth mentioning you change/investigate if you're interested in tweaking the config files some more:
- If you'd like to directly connect to the Neo4j database, you have to uncomment two lines in the config file.
	- By default, the username and password for BHCE's Neo4j database is neo4j:bloodhoundcommunityedition
		- This should be changed before making them public facing.
	- PostgreSQL suffers the same issue
 - Binding to a specific interface's IP address instead of quad 0 may be better if you don't want to bind to your loopback interface.

### Backgrounding Docker
This is our last section - Backgrounding our docker container. We've made a lot of good configuration changes. Don't be like me, go away for lunch, shut the laptop and one of your coworkers tries to access the BHCE instance and it's not working. Why's that? The SSH connection to your BHCE server was terminated!

To prevent this, we're going to detach the container by stopping the container and restarting it with the following command:
```bash
docker-compose up -d
```

This will start BHCE as a backgrounded process:
![[Pasted image 20230820011455.png]](https://blog.spookysec.net/img/Pasted image 20230820011455.png)

If you make a change and need to restart one of the containers, or shut them down for some reason, you can run the following command to shutdown the container:
```
docker-compose down
```

I recommend creating some aliases to do this just to expedite the process, especially if you're not a Docker power-user. This is my first real experience with using Docker and it's been a bit of a struggle, so I thought I'd share some of the things I learned just to help make your all's life a little bit easier.

Anyways, I hope this helps :D

~ Ronnie
