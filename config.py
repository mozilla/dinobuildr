import subprocess, glob, json, os, hashlib

local_repo = 'repo'
os.environ["repo"] = local_repo

def pkg_install(package):
    pipes = subprocess.Popen(["sudo","installer","-pkg",package,"-target","/"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode

def script_exec(script):
    pipes = subprocess.Popen(["/bin/bash","-c",script], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode

def hash_file(filename):
    hash = hashlib.sha256()
    with open (filename, 'rb') as file:
        for chunk in iter(lambda: file.read(4096), b""):
            hash.update(chunk)
    return hash.hexdigest() 

with open ('manifest.json', 'r') as manifest_file:
    data = json.load(manifest_file)
    for item in data['packages']:
        hash = hash_file(item['path'])
        if hash == item['hash']:
            print "The hash:", hash, "matches what we expect."
            if ".pkg" in item['name']: 
                print "Installing:", item['name']
                pkg_install(item['path'])
            if ".sh" in item['name']:
                print "Executing:", item['name']
                script_exec(item['path'])
        else: 
            print "The hash:", hash, "does not match the hash in the manifest:", item['hash']
    manifest_file.close()
