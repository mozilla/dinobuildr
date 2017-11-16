#!/usr/bin/env python

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

import os
import hashlib
import json
import getpass
import urllib2
import base64
import re
from collections import OrderedDict

# local_dir -  the local directory we will use to cache packages for
# hashing/testing
# org - the org that is hosting the build repository
# repo - the repo that is hosting the build
# branch - the branch that we are using. useful to change this if developing /
# testing
local_dir = 'build-temp'
org = "mozilla"
repo = "dinobuildr"
branch = "feat-crashplanquit"

# lfs_url - the generic LFS url structure that github uses
# raw_url -  the generic RAW url structure that github uses
lfs_url = "https://github.com/%s/%s.git/info/lfs/objects/batch" % (org, repo)
raw_url = "https://raw.githubusercontent.com/%s/%s/%s/" % (org, repo, branch)


# the downloader function accepts three arguments: the url of the file you are
# downloading, the filename (path) of the file you are downloading and an
# optional password if the download requires Basic authentication. the
# downloader reads the Content-Length portion of the header of the incoming
# file and determines the expected file size then reads the incoming file in
# chunks of 8192 bytes and displays the currently read bytes and percentage
# complete.
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
            status = status + chr(8) * (len(status) + 1)
            print "\r", status,
            if len(data) < chunk_size:
                break


# the hash_file function accepts two arguments: the filename that you need to
# determine the SHA256 hash of and the expected hash it returns True or False.
def hash_file(filename):
    hash = hashlib.sha256()
    with open(filename, 'rb') as file:
        for chunk in iter(lambda: file.read(4096), b""):
            hash.update(chunk)
    return hash.hexdigest()


# the pointer_to_json function accepts the url of the file in the github repo
# and the password to the repo. the pointer file is read from github then
# parsed and the "oid sha256" and "size" are extracted from the pointer. an
# object is returned that contains a json request for the file that the pointer
# is associated with.
# TODO: password should be optional in the prod version.
def pointer_to_json(dl_url, password):
    content_req = urllib2.Request(dl_url)
    content_req.add_header("Authorization", "Basic %s" % password)
    content_result = urllib2.urlopen(content_req)
    output = content_result.read()
    content_result.close()
    oid = re.search('(?m)^oid sha256:([a-z0-9]+)$', output)
    size = re.search('(?m)^size ([0-9]+)$', output)
    json_data = (
        '{"operation": "download", '
        '"transfers": ["basic"], '
        '"objects": [{"oid": "%s", "size": %s}]}' % (oid.group(1), size.group(1)))
    return json_data


# the get_lfs_url function makes a request the the lfs API of the github repo,
# receives a JSON response then gets the download URL from the JSON response
# and returns it.
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


# where the action happens - for more details, see config.py. this section
# should be identical, save for the part the executes stuff.
if os.path.isfile('manifest.json'):
    # TODO: we're doing this because this is a private repo
    user = raw_input("Enter github username: ").replace('\n', '')
    password = getpass.getpass("Enter github password or PAT: ")
    base64string = base64.encodestring('%s:%s' % (user, password)).replace('\n', '')

    with open('manifest.json', 'r') as outfile:
            manifest = json.load(outfile, object_pairs_hook=OrderedDict)
            for item in manifest['packages']:
                if item['filename'] != "":
                    file_name = item['filename']
                else:
                    file_name = (
                        item['url'].replace('${version}', item['version'])
                    ).rsplit('/', 1)[-1]

                local_path = "%s/%s" % (local_dir, file_name)

                if item['type'] == "pkg-lfs":
                    dl_url = raw_url + item['url']
                    json_data = pointer_to_json(dl_url, base64string)
                    lfsfile_url = get_lfs_url(json_data, base64string, lfs_url)
                    print "Downloading:", item['item']
                    downloader(lfsfile_url, local_path)
                    item['hash'] = hash_file(local_path)

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
                    item['hash'] = hash_file(local_path)

                if item['type'] == "file-lfs":
                    if item['url'] == '':
                        print "No URL specified for %s" % item['item']
                        break
                    dl_url = raw_url + item['url']
                    json_data = pointer_to_json(dl_url, base64string)
                    lfsfile_url = get_lfs_url(json_data, base64string, lfs_url)
                    print "Downloading:", item['item']
                    downloader(lfsfile_url, local_path)
                    item['hash'] = hash_file(local_path)
    outfile.close()

else:
    print "Creating a manifest.json..."

    manifest = {}
    manifest['packages'] = []

    if os.path.isfile("order.txt"):
        with open('order.txt', 'r') as orderfile:
            for item in orderfile:
                item_name = item.rstrip()
                manifest['packages'].append(OrderedDict([
                    ['item', item_name],
                    ['version', ""],
                    ['url', ""],
                    ['filename', ""],
                    ['dmg-installer', ""],
                    ['dmg-advanced', ""],
                    ['hash', ""],
                    ['type', ""]
                ]))
        orderfile.close()

    else:
        print "order.txt file required to generate a manifest."

with open('manifest.json', 'w') as outfile:
    json.dump(manifest, outfile, indent=4, sort_keys=False)
outfile.close()

manifest_hash = hash_file('manifest.json')
print "File created. The manifest has a hash of:", manifest_hash
