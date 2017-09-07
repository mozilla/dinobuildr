import subprocess, glob, json, os, hashlib

local_repo = 'repo'
os.environ["repo"] = local_repo

user = raw_input("Enter github username: ")
password = raw_input("Enter Github password: ")

def downloader(user, password, url, filename):
    curl_cmd = 'curl -o %s -u %s:%s -H "Accept: application/vnd.github.raw" "%s"' % (filename, user, password, url)
    sudo_cmd = 'sudo chmod +x %s' % filename
    pipes = subprocess.Popen(["curl", "-o", filename, "-u", user + ":" + password, "-H", "Accept: application/vnd.github.raw", url], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode
    pipes = subprocess.Popen(["sudo", "chmod", "+x", filename], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode

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
        downloader(user, password, item['url'], item['local_path'])
        hash = hash_file(item['local_path'])
        if hash == item['hash']:
            print "The hash:", hash, "matches what we expect."
            if ".pkg" in item['name']: 
                
                print "Installing:", item['name']
                pkg_install(item['local_path'])
            if ".sh" in item['name']:
                print "Executing:", item['name']
                script_exec(item['local_path'])
        else: 
            print "The hash:", hash, "does not match the hash in the manifest:", item['hash']
    manifest_file.close()
