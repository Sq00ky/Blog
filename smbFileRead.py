#!/usr/bin/python3
import argparse
from impacket.smbconnection import SMBConnection
from io import BytesIO

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