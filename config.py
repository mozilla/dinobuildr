import subprocess, glob, json, os, hashlib, urllib2, base64, re, getpass, stat, shutil

# set org, repo and branch that hosts the packages and scripts as well as the temporary working directory
# that we will use to store scripts
# we also determine the path of the script we are executing for later cleanup

org = "mozilla"
repo = "dinobuildr"
branch = "feat-dmgsupport"
local_dir = "/var/tmp/dinobuildr"
script_path = os.path.realpath(__file__)

# set lfs and raw urls
# set the url of the manifest file that this script will pull down
# the manifest hash MUST change whenever changes are made to the manifest
# we set the manifest file location against the temporary working directory we specify

lfs_url = "https://github.com/%s/%s.git/info/lfs/objects/batch" % (org, repo)
raw_url = "https://raw.githubusercontent.com/%s/%s/%s/" % (org, repo, branch)
manifest_url= "https://raw.githubusercontent.com/%s/%s/%s/manifest.json" % (org, repo, branch)
manifest_hash = "bd4719aa47171ee7f835cfb06b36884bc6e69b3e07fb88c81cdedea7a963bdeb"
manifest_file = "%s/manifest.json" % local_dir

# authenticate to github since this is a private repo
# base64string is really just a variable that stores the username and password in this format: username:password

user = raw_input("Enter github username: ").replace('\n','')
password = getpass.getpass() 
base64string = base64.encodestring('%s:%s' % (user, password)).replace('\n','')

# the downloader function accepts three arguments: the url of the file you are downloading, the filename (path) of the file you are
# downloading and an optional password if the download requires Basic authentication
# the downloader reads the Content-Length portion of the header of the incoming file and determines the expected file size
# then reads the incoming file in chunks of 8192 bytes and displays the currently read bytes and percentage complete

def downloader(url, filename, password=None):
    dir_path = (re.search(".*\/", filename)).group(0)
    print dir_path
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)
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

# the package installer function runs the installer binary in MacOS and pipes stdout and stderr to the python console
# the return code of the package run can be found in the pipes object (pipes.returncode)

def pkg_install(package):
    pipes = subprocess.Popen(["sudo","installer","-pkg",package,"-target","/"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode

# the script executer executes any .sh file using bash and pipes stdout and stderr to the python console
# the return code of the script execution can be found in the pipes object (pipes.returncode)

def script_exec(script):
    pipes = subprocess.Popen(["/bin/bash","-c",script], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode

# the hash_file function accepts two arguments: the filename that you need to determine the SHA256 hash of
# and the expected hash
# it returns True or False

def hash_file(filename, man_hash):
    hash = hashlib.sha256()
    with open (filename, 'rb') as file:
        for chunk in iter(lambda: file.read(4096), b""):
            hash.update(chunk)
    if hash.hexdigest() == man_hash:
        return True
    else: 
        return False

# the pointer_to_json function accepts the url of the file in the github repo and the password to the repo
# the pointer file is read from github then parsed and the "oid sha256" and "size" are extracted from the pointer
# an object is returned that contains a json request for the file that the pointer is associated with
# todo: password should be optional

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

# the get_lfs_url function makes a request the the lfs API of the github repo, receives a JSON response
# then gets the download URL from the JSON response and returns it.

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

if not os.path.exists(local_dir):
    os.makedirs(local_dir)

# download the manifest.json file

downloader(manifest_url, manifest_file, base64string)

# check the hash of the incoming manifest file and bail if the hash doesn't match

if hash_file(manifest_file, manifest_hash) == False:
    print "Manifest file hash does not match the expected hash. Make sure you are using the latest version of this script."
    exit()

# we read the manifest file and examine each object in it
# if the object is a .pkg file, then we assemble the download url of the pointer, read the pointer and request the file from LFS
# if the file we get has a hash that matches what's in the manifest, we call the installer function
# if the object is a .sh file, we assmble the download url and download the file directly
# if the script we get has a hash that matches what's in the manifest, we set the execute flag and call the script_exec function 

with open (manifest_file, 'r') as manifest_file:
    data = json.load(manifest_file)
    
    for item in data['packages']:
        if item['type'] == "pkg-lfs": 
            dl_url = raw_url + item['url']
            local_path = "%s/%s" % (local_dir, item['url']) 
            json_data = pointer_to_json(dl_url, base64string)
            lfsfile_url = get_lfs_url(json_data, base64string, lfs_url)
            print "Downloading:", item['item']
            downloader(lfsfile_url, local_path)
            if hash_file(local_path, item['hash']) == True:
                print "The hash for %s match the manifest file" % item['item']
                print "Installing:", item['item']
                pkg_install(local_path)
            else:
                print "WARNING: The the hash for %s does not match the manifest file."
        if ".sh" in item['shell']:
            print "Downloading:", item['item']
            downloader(dl_url, local_path, base64string)
            if hash_file(local_path, item['hash']) == True:
                print "The hash for %s match the manifest file" % item['item']
                print "Executing:", item['item']
                perms = os.stat(local_path)
                os.chmod(local_path, perms.st_mode | stat.S_IEXEC)
                script_exec(local_path)
            else:
                print "WARNING: The the hash for %s does not match the manifest file."

# delete the temporary directory we've been downloading packages into and the config script
print "Cleanup: Deleting %s" % local_dir
shutil.rmtree(local_dir)
print "Cleanup: Deleting %s" % script_path
os.remove(script_path)
