import subprocess, glob, json, os, hashlib, urllib2, base64, re, getpass, stat

local_repo = 'repo'

org = "mozilla"
repo = "dinobuildr"
branch = "master"

lfs_url = "https://github.com/%s/%s.git/info/lfs/objects/batch" % (org, repo)
raw_url = "https://raw.githubusercontent.com/%s/%s/%s/%s/" % (org, repo, branch, local_repo)
manifest_url= "https://raw.githubusercontent.com/%s/%s/%s/manifest.json" % (org, repo, branch)

user = raw_input("Enter github username: ").replace('\n','')
password = getpass.getpass() 
base64string = base64.encodestring('%s:%s' % (user, password)).replace('\n','')

def downloader(url, filename, password=None):
    download_req = urllib2.Request(url)
    if password: 
        download_req.add_header("Authorization", "Basic %s" % password)
    download = urllib2.urlopen(download_req)
    meta = download.info()
    file_size = int(meta.getheaders("Content-Length")[0])
    print "%s is %s bytes." % (filename, file_size)
    with open(filename, 'wb') as code:
        chunk_size = 8192
        bytes_read = 0
        while True:
            data = download.read(chunk_size)
            bytes_read += len(data)
            code.write(data)
            status = r"%10d [%3.2f%%]" % (bytes_read, bytes_read * 100 / file_size)
            status = status + chr(8)*(len(status)+1)
            print status, 
            if len(data) < chunk_size:
                break

def pkg_install(package):
    pipes = subprocess.Popen(["sudo","installer","-pkg",package,"-target","/"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode

def script_exec(script):
    pipes = subprocess.Popen(["/bin/bash","-c",script], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode

def hash_file(filename, man_hash):
    hash = hashlib.sha256()
    with open (filename, 'rb') as file:
        for chunk in iter(lambda: file.read(4096), b""):
            hash.update(chunk)
    if hash.hexdigest() == man_hash:
        return True

def get_lfs_url(json_input, password, lfs_url):
    req = urllib2.Request(lfs_url, json_input)
    req.add_header("Authorization", "Basic %s" % password)
    req.add_header("Accept", "application/vnd.git-lfs+json")
    req.add_header("Content-Type", "application/vnd.git-lfs+json")
    result = urllib2.urlopen(req)
    results_python = json.load(result)
    file_url = results_python['objects'][0]['actions']['download']['href']
    result.close()
    return file_url

def pointer_to_json(dl_url, password):
    content_req = urllib2.Request(dl_url)
    content_req.add_header("Authorization", "Basic %s" % password)
    content_result = urllib2.urlopen(content_req)
    output = content_result.read()
    content_result.close()
    oid = re.search('(?m)^oid sha256:([a-z0-9]+)$', output)
    size = re.search('(?m)^size ([0-9]+)$', output)
    json_data = '{"operation": "download", "transfers": ["basic"], "objects": [{"oid": "%s", "size": %s}]}' % (oid.group(1), size.group(1))
    return json_data 

if not os.path.exists(local_repo):
    os.makedirs(local_repo)

downloader(manifest_url, "manifest.json", base64string)

with open ('manifest.json', 'r') as manifest_file:
    data = json.load(manifest_file)
    
    for item in data['packages']:
        if ".pkg" in item['name']: 
            dl_url = raw_url + item['name']
            local_path = "repo/" + item['name']
            json_data = pointer_to_json(dl_url, base64string)
            lfsfile_url = get_lfs_url(json_data, base64string, lfs_url)
            print "Downloading:", item['name']
            downloader(lfsfile_url, local_path)
            if hash_file(local_path, item['hash']) == True:
                print "The hash for %s match the manifest file" % item['name']
                print "Installing:", item['name']
                pkg_install(item['local_path'])
            else:
                print "WARNING: The the hash for %s does not match the manifest file."
        if ".sh" in item['name']:
            print "Downloading:", item['name']
            dl_url = raw_url + item['name']
            local_path = "repo/" + item['name']
            downloader(dl_url, local_path, base64string)
            if hash_file(local_path, item['hash']) == True:
                print "The hash for %s match the manifest file" % item['name']
                print "Executing:", item['name']
                perms = os.stat(item['local_path'])
                os.chmod(item['local_path'], perms.st_mode | stat.S_IEXEC)
                script_exec(item['local_path'])
            else:
                print "WARNING: The the hash for %s does not match the manifest file."
