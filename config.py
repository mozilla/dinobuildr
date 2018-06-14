#!/usr/bin/env python

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

import subprocess
import json
import os
import hashlib
import urllib2
import re
import stat
import shutil
import shlex
import pwd
import grp
import argparse
from SystemConfiguration import SCDynamicStoreCopyConsoleUser

# --- section 1: defining too many variables --------------------- #
# in this section we define way too many variables and things.
# ---------------------------------------------------------------- #

# globalize the uid and gid variables so the DMG installer can use it without
# needing to pass it every time.
# TODO: this is lazy and a better method should be used.
global uid
global gid

# local_dir - the local directory the builder will use
# org - the org that is hosting the build repository
# repo - the rep that is hosting the build
# default_branch - the default branch to build against if no --branch argument is specified
# testing
local_dir = "/var/tmp/dinobuildr"
org = "mozilla"
repo = "dinobuildr"
default_branch = "master"
default_manifest = "manifest.json"

# this section parses argument(s) passed to this script
# the --branch argument specified the branch that this script will build
# against, which is useful for testing. the script will default to the master
# branch if no argument is specified. 
parser = argparse.ArgumentParser()
parser.add_argument("-b", "--branch", help="The branch name to build against. Defaults to %s" % default_branch)
parser.add_argument("-m", "--manifest", help="The manifest to build against. Defaults to production macOS deployment.")

args = parser.parse_args()

if args.branch == None:
    branch = default_branch
else:
    branch = args.branch

if args.manifest == None:
    manifest = default_manifest
else:
    manifest = args.manifest

# os.environ - an environment variable for the builder's local directory to be
# passed on to shells scripts
# current_user - the name of the user running the script. Apple suggests using
# both methods.
# uid - the UID of the user running the script
# gid - the GID of the group "staff" which is the default primary group for all
# users in macOS
os.environ["DINOPATH"] = local_dir
current_user = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]
current_user = [current_user, ""][current_user in [u"loginwindow", None, u""]]
uid = pwd.getpwnam(current_user).pw_uid
gid = grp.getgrnam("staff").gr_gid

# lfs_url -  the generic LFS url structure that github uses
# raw_url - the generic RAW url structure that github uses
# manifest_url - the url of the manifest file
# manifest_hash - the hash of the manifest file
# manifest_file - the expected filepath of the manifest file
lfs_url = "https://github.com/%s/%s.git/info/lfs/objects/batch" % (org, repo)
raw_url = "https://raw.githubusercontent.com/%s/%s/%s/" % (org, repo, branch)
manifest_url = "https://raw.githubusercontent.com/%s/%s/%s/%s" % (org, repo, branch, manifest)
manifest_file = "%s/%s" % (local_dir, manifest)
default_manifest_hash = "61f6fc9b2bf9f2711c9eb4e2e9032dc825534fba83b02db0f1fcda09fb3fbdb5"
ambient_manifest_hash = "9c70382c40f271bddb4136a9e2d7add0f22451e0c8fe87ccd10ce91d9bc0f367"
manifest_hash = default_manifest_hash
if manifest == "ambient_manifest.json":
    manifest_hash = ambient_manifest_hash


# check to see if user ran with sudo , since it's required

if os.getuid() != 0:
    print "This script requires root to run, please try again with sudo."
    exit(1)

# --- section 2: functions on functions on functions -------------------- #
# in this section we define all the important functions we will use.
# ----------------------------------------------------------------------- #


# the downloader function accepts three arguments: the url of the file you are
# downloading, the filename (path) of the file you are downloading and an
# optional password if the download requires Basic authentication. the
# downloader reads the Content-Length portion of the header of the incoming
# file and determines the expected file size then reads the incoming file in
# chunks of 8192 bytes and displays the currently read bytes and percentage
# complete

def downloader(url, file_path):
    if not os.path.exists(local_dir):
        os.makedirs(local_dir)
    download = urllib2.urlopen(url)
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


# the package installer function runs the installer binary in macOS and pipes
# stdout and stderr to the python console the return code of the package run
# can be found in the pipes object (pipes.returncode). this is the reason we
# need to run   # this is the bit where we can accept an optional command with
# arguments
def pkg_install(package):
    pipes = subprocess.Popen([
        "sudo",
        "installer", "-pkg", package, "-target", "/"],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    if err:
        print err.decode('utf-8')


# the script executer executes any .sh file using bash and pipes stdout and
# stderr to the python console. the return code of the script execution can be
# found in the pipes object (pipes.returncode).
def script_exec(script):
    pipes = subprocess.Popen([
        "/bin/bash", "-c", script],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(pipes.stdout.readline, b''):
        print("*** " + line.rstrip())
    pipes.communicate()
    if pipes.returncode == 1:
        exit(1)


# the dmg installer is by far the most complicated function, because DMGs are
# more complicated than a .app inside we take the appropriate action. we also
# have the option to specify an optional command. since sometimes we must
# execute installer .apps or pkgs buried in the .app bundle, which is annoying.
def dmg_install(filename, installer, command=None):
    pipes = subprocess.Popen([
        "hdiutil", "attach", filename],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    if err:
        print err.decode('utf-8')
    volume_path = re.search("(\/Volumes\/).*$", out).group(0)
    installer_path = "%s/%s" % (volume_path, installer)
    if command is not None and installer == '':
        command = command.replace('${volume}', volume_path).encode("utf-8")
        command = shlex.split(command)
        pipes = subprocess.Popen(
            command,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = pipes.communicate()
        if err:
            print err.decode('utf-8')
    if ".pkg" in installer:
        installer_destination = "%s/%s" % (local_dir, installer)
        shutil.copyfile(installer_path, installer_destination)
        pkg_install(installer_path)
    if ".app" in installer:
        applications_path = "/Applications/%s" % installer.rsplit('/', 1)[-1]
        if os.path.exists(applications_path):
            shutil.rmtree(applications_path)
        shutil.copytree(installer_path, applications_path)
        os.chown(applications_path, uid, gid)
        os.chmod(applications_path, 0o755)
    pipes = subprocess.Popen([
        "hdiutil", "detach", volume_path],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    if err:
        print err.decode('utf-8')

# the mobileconfig_install function installs configuration profiles
def mobileconfig_install(mobileconfig):
    pipes = subprocess.Popen([
        "/usr/bin/profiles", "-I", "-F" mobileconfig],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    if err:
        print err.decode('utf-8')

# the hash_file function accepts two arguments: the filename that you need to
# determine the SHA256 hash of and the expected hash it returns True or False.
def hash_file(filename, man_hash):
    if man_hash == "skip":
        print "NOTICE: Manifest file is instructing us to SKIP hashing %s." % filename
    else:
        hash = hashlib.sha256()
        with open(filename, 'rb') as file:
            for chunk in iter(lambda: file.read(4096), b""):
                hash.update(chunk)
        if hash.hexdigest() == man_hash:
            print "\rThe hash for %s match the manifest file" % filename
            return True
        else:
            print "WARNING: The the hash for %s is unexpected." % filename
            exit(1)


# the pointer_to_json function accepts the url of the file in the github repo
# and the password to the repo. the pointer file is read from github then
# parsed and the "oid sha256" and "size" are extracted from the pointer. an
# object is returned that contains a json request for the file that the pointer
# is associated with.
def pointer_to_json(dl_url):
    content_result = urllib2.urlopen(dl_url)
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
# receives a JSON response. then gets the download URL from the JSON response
# and returns it.
def get_lfs_url(json_input, lfs_url):
    req = urllib2.Request(lfs_url, json_input)
    req.add_header("Accept", "application/vnd.git-lfs+json")
    req.add_header("Content-Type", "application/vnd.git-lfs+json")
    result = urllib2.urlopen(req)
    results_python = json.load(result)
    file_url = results_python['objects'][0]['actions']['download']['href']
    result.close()
    return file_url


# --- section 3: actually doing stuff! --------------------- #
# now the fun bit: we actually get to do stuff!
# ---------------------------------------------------------- #

# if the local directory doesn't exist, we make it.
if not os.path.exists(local_dir):
    os.makedirs(local_dir)

# download the manifest.json file.
print "\nDownloading the manifest file and hash-checking it.\n"
downloader(manifest_url, manifest_file)

# check the hash of the incoming manifest file and bail if the hash doesn't match.
hash_file(manifest_file, manifest_hash)

print "\n***** DINOBUILDR IS BUILDING. RAWR. *****\n"
print "Building against the [%s] branch and the %s manifest\n" % (branch, manifest)
# we read the manifest file and examine each object in it. if the object is a
# .pkg file, then we assemble the download url of the pointer, read the pointer
# and request the file from LFS. if the file we get has a hash that matches
# what's in the manifest, we Popen the installer function if the object is a
# .sh file, we assemble the download url and download the file directly. if the
# script we get has a hash that matches what's in the manifest, we set the
# execute flag and Popen the script_exec function. same with dmgs, although
# dmgs are real complicated so we may end up running an arbitrary command,
# copying the installer or installing a pkg.
with open(manifest_file, 'r') as manifest_data:
    data = json.load(manifest_data)

for item in data['packages']:
    if item['filename'] != "":
        file_name = item['filename']
    else:
        file_name = (
            item['url'].replace('${version}', item['version'])
        ).rsplit('/', 1)[-1]
    # TODO: this variable name is dumb, this is the path to the file we're
    # working with
    local_path = "%s/%s" % (local_dir, file_name)

    if item['type'] == "pkg-lfs":
        dl_url = raw_url + item['url']
        json_data = pointer_to_json(dl_url)
        lfsfile_url = get_lfs_url(json_data, lfs_url)
        print "Downloading:", item['item']
        downloader(lfsfile_url, local_path)
        hash_file(local_path, item['hash'])
        pkg_install(local_path)
        print "\r"

    if item['type'] == "shell":
        dl_url = raw_url + item['url']
        print "Downloading:", item['item']
        downloader(dl_url, local_path)
        hash_file(local_path, item['hash'])
        print "Executing:", item['item']
        perms = os.stat(local_path)
        os.chmod(local_path, perms.st_mode | stat.S_IEXEC)
        script_exec(local_path)
        print "\r"

    if item['type'] == "dmg":
        # TODO: consisitency: there should be URL checks everywhere or do this
        # in the manifest generator
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
        print "\r"

    if item['type'] == "file-lfs":
        if item['url'] == '':
            print "No URL specified for %s" % item['item']
            break
        dl_url = raw_url + item['url']
        json_data = pointer_to_json(dl_url)
        lfsfile_url = get_lfs_url(json_data, lfs_url)
        print "Downloading:", item['item']
        downloader(lfsfile_url, local_path)
        hash_file(local_path, item['hash'])
        print "\r"

    if item['type'] == "mobileconfig":
        dl_url = raw_url + item['url']
        print "Downloading:", item['item']
        downloader(dl_url, local_path)
        hash_file(local_path, item['hash'])
        print "Installing:", item['item']
        mobileconfig_install(local_path)
        print "\r"

# delete the temporary directory we've been downloading packages into.
print "Cleanup: Deleting %s" % local_dir
shutil.rmtree(local_dir)

print "Build complete!"
