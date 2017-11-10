import glob, os, hashlib, json, getpass, urllib2, base64, re, collections
from collections import OrderedDict

local_dir = 'build-temp'
org = "mozilla"
repo = "dinobuildr"
branch = "master"

lfs_url = "https://github.com/%s/%s.git/info/lfs/objects/batch" % (org, repo)
raw_url = "https://raw.githubusercontent.com/%s/%s/%s/" % (org, repo, branch)

def downloader(url, file_path, password=None):
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

def hash_file(filename):
    hash = hashlib.sha256()
    with open (filename, 'rb') as file:
        for chunk in iter(lambda: file.read(4096), b""):
            hash.update(chunk)
    return hash.hexdigest() 

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

if os.path.isfile('manifest.json'):
    user = raw_input("Enter github username: ").replace('\n','')
    password = getpass.getpass("Enter github password or PAT: ") 
    base64string = base64.encodestring('%s:%s' % (user, password)).replace('\n','')

    with open ('manifest.json', 'r') as outfile:
            manifest = json.load(outfile, object_pairs_hook=OrderedDict)
            for item in manifest['packages']:  
                if item['filename'] != "":
                    file_name = item['filename']
                else: 
                    file_name = (item['url'].replace('${version}', item['version'])).rsplit('/', 1)[-1]
                
                local_path = "%s/%s" % (local_dir, file_name)
                 
                if item['type'] == "pkg-lfs": 
                    dl_url = raw_url + item['url']
                    json_data = pointer_to_json(dl_url, base64string)
                    lfsfile_url = get_lfs_url(json_data, base64string, lfs_url)
                    print "Downloading:", item['item']
                    downloader(lfsfile_url, local_path)
                    item['hash'] =  hash_file(local_path)
                
                if item['type'] == "shell":
                    dl_url = raw_url + item['url']
                    print "Downloading:", item['item']
                    downloader(dl_url, local_path, base64string)
                    item['hash'] = hash_file(local_path)
                
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
                    item['hash'] =  hash_file(local_path)

                if item['type'] == "file-lfs":
                    if item['url'] == '':
                        print "No URL specified for %s" % item['item']
                        break
                    dl_url = raw_url + item['url']
                    json_data = pointer_to_json(dl_url, base64string)
                    lfsfile_url = get_lfs_url(json_data, base64string, lfs_url)
                    print "Downloading:", item['item']
                    downloader(lfsfile_url, local_path)
                    item['hash'] =  hash_file(local_path)
    outfile.close() 
    
else: 
    print "Creating a manifest.json..."
    
    manifest = {}
    manifest['packages'] = [] 
 
    if os.path.isfile("order.txt"):
        with open ('order.txt', 'r') as orderfile:
            for item in orderfile:
                item_name = item.rstrip()
                manifest['packages'].append(OrderedDict([
                    ['item', item_name],
                    ['version', ""],
                    ['url' , ""],
                    ['filename', ""],
                    ['dmg-installer' , ""],
                    ['dmg-advanced', ""],
                    ['hash', ""],
                    ['type' , ""]
                    ]))
        orderfile.close()       
        
    else: 
        print "order.txt file required to generate a manifest."

with open ('manifest.json', 'w') as outfile:
    json.dump(manifest, outfile, indent=4, sort_keys=False)
outfile.close()

manifest_hash = hash_file('manifest.json')
print "File created. The manifest has a hash of:", manifest_hash
