import subprocess, glob, json, os, hashlib, urllib2, base64, re, getpass, stat, shutil

# set org, repo and branch that hosts the packages and scripts as well as the temporary working directory
# that we will use to store scripts
# we also determine the path of the script we are executing for later cleanup

local_dir = "/var/tmp/dinobuildr"
org = "mozilla"
repo = "dinobuildr"
branch = "feat-dmgsupport"
script_path = os.path.realpath(__file__)

# set lfs and raw urls
# set the url of the manifest file that this script will pull down
# the manifest hash MUST change whenever changes are made to the manifest
# we set the manifest file location against the temporary working directory we specify

lfs_url = "https://github.com/%s/%s.git/info/lfs/objects/batch" % (org, repo)
raw_url = "https://raw.githubusercontent.com/%s/%s/%s/" % (org, repo, branch)
manifest_url= "https://raw.githubusercontent.com/%s/%s/%s/manifest.json" % (org, repo, branch)
manifest_hash = "a86ab3727cd3aeaa079bd87026ec4a25ca1425bbbafba042d8ec8f0cca4ad932"
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

def downloader(url, file_path, password=None):
    print url
    if not os.path.exists(local_dir):
        os.makedirs(local_dir)
    download_req = urllib2.Request(url)
    if password: 
        download_req.add_header("Authorization", "Basic %s" % password)
    download = urllib2.urlopen(download_req)
    meta = download.info()
    file_size = int(meta.getheaders("Content-Length")[0])
    print "%s is %s bytes." % (file_path, file_size)
    with open(file_path, 'wb') as code:
        chunk_size = 8192
        bytes_read = 0
        while True:
            data = download.read(chunk_size)
            bytes_read += len(data)
            code.write(data)
            status = r"%10d [%3.2f%%]" % (bytes_read, bytes_read * 100 / file_size)
            status = status + chr(8)*(len(status)+1)
            print "\r", status, 
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

def dmg_install(filename, installer, command=None):
    print filename
    pipes = subprocess.Popen(["hdiutil","attach",filename], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode
    volume_path = re.search("(\/Volumes\/).*$", out).group(0) 
    print volume_path
    installer_path = "%s/%s" % (volume_path, installer)
    if command != None and installer == '': 
        command = command.split()
        print command
        print [cmd.replace('${volume}', volume_path).encode("utf-8") for cmd in command]
        pipes = subprocess.Popen([cmd.replace('${volume}', volume_path.replace(' ', '\ ')).encode("utf-8") for cmd in command], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = pipes.communicate()
        print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode
    if ".pkg" in installer: 
        installer_destination= "%s/%s" % (local_dir, installer)
        shutil.copyfile(installer_path, installer_destination)
        pkg_install(installer_path)
    if ".app" in installer:
        applications_path = "/Applications/%s" % installer
        if os.path.exists(applications_path):
            shutil.rmtree(applications_path)
        shutil.copytree(installer_path, applications_path)
    pipes = subprocess.Popen(["hdiutil","detach",volume_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode

def hash_file(filename, man_hash):
    if man_hash == "skip":
        print "NOTICE: Manifest file is instructing us to SKIP hashing %s." % filename
    else:     
        hash = hashlib.sha256()
        with open (filename, 'rb') as file:
            for chunk in iter(lambda: file.read(4096), b""):
                hash.update(chunk)
        if hash.hexdigest() == man_hash:
            print "The hash for %s match the manifest file" % item['item']
            return True
        else: 
            print "WARNING: The the hash for %s is unexpected." % filename
            exit(1)

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

# hash_file(manifest_file, manifest_hash)

# we read the manifest file and examine each object in it
# if the object is a .pkg file, then we assemble the download url of the pointer, read the pointer and request the file from LFS
# if the file we get has a hash that matches what's in the manifest, we call the installer function
# if the object is a .sh file, we assmble the download url and download the file directly
# if the script we get has a hash that matches what's in the manifest, we set the execute flag and call the script_exec function 

with open (manifest_file, 'r') as manifest_data:
    data = json.load(manifest_data)
    
for item in data['packages']:
    print item
    if item['filename'] != "":
        file_name = item['filename']
    else: 
        file_name = (item['url'].replace('${version}', item['version'])).rsplit('/', 1)[-1]
    
    print file_name
    local_path = "%s/%s" % (local_dir, file_name)
     
    if item['type'] == "pkg-lfs": 
        dl_url = raw_url + item['url']
        json_data = pointer_to_json(dl_url, base64string)
        lfsfile_url = get_lfs_url(json_data, base64string, lfs_url)
        print "Downloading:", item['item']
        downloader(lfsfile_url, local_path)
        hash_file(local_path, item['hash'])
        pkg_install(local_path)
    
    if item['type'] == "shell":
        dl_url = raw_url + item['url']
        print "Downloading:", item['item']
        downloader(dl_url, local_path, base64string)
        hash_file(local_path, item['hash'])
        print "Executing:", item['item']
        perms = os.stat(local_path)
        os.chmod(local_path, perms.st_mode | stat.S_IEXEC)
        script_exec(local_path)
    
    if item['type'] == "dmg":
        if item['url'] == '':
            print "No URL specified for %s" % item['item']
            break
        if item['dmg-installer'] == '' and item['dmg-advanced'] == '':
           print "No installer or install command specified for %s" % item['item']
           break
        dl_url = item['url'].replace('${version}', item['version'])
        print "Downloading:", item['item']
        downloader(dl_url, local_path)
        hash_file(local_path, item['hash'])
        print local_path
        print item['dmg-installer']
        if item['dmg-installer'] != '':
            dmg_install(local_path, item['dmg-installer']) 
        if item['dmg-advanced'] != '':
            dmg_install(local_path, '', item['dmg-advanced'])
# delete the temporary directory we've been downloading packages into and the config script
print "Cleanup: Deleting %s" % local_dir
shutil.rmtree(local_dir)
print "Cleanup: Deleting %s" % script_path
#os.remove(script_path)
