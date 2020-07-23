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


# the downloader function accepts two arguments: the url of the file you are
# downloading and the filename (path) of the file you are downloading. The
# downloader reads the Content-Length portion of the header of the incoming
# file and determines the expected file size then reads the incoming file in
# chunks of 8192 bytes and displays the currently read bytes and percentage
# complete
def downloader(url, file_path):
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
    pipes = subprocess.Popen(["sudo", "installer", "-pkg", package, "-target", "/"],
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = pipes.communicate()
    if pipes.returncode == 1:
        print stdout
        print stderr
        exit(1)


# the script executer executes any .sh file using bash and pipes stdout and
# stderr to the python console. the return code of the script execution can be
# found in the pipes object (pipes.returncode).
def script_exec(script):
    pipes = subprocess.Popen(["/bin/bash", "-c", script],
                             stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(pipes.stdout.readline, b''):
        print "*** " + line.rstrip()
    pipes.communicate()
    if pipes.returncode == 1:
        exit(1)


# the dmg installer is by far the most complicated function, because DMGs are
# more complicated than a .app inside we take the appropriate action. we also
# have the option to specify an optional command. since sometimes we must
# execute installer .apps or pkgs buried in the .app bundle, which is annoying.
def dmg_install(filename, installer, command=None):
    pipes = subprocess.Popen(["hdiutil", "attach", filename], stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)
    stdout, stderr = pipes.communicate()
    if pipes.returncode == 1:
        print stdout
        print stderr
        exit(1)
    volume_path = re.search(r'(\/Volumes\/).*$', stdout).group(0)
    installer_path = "%s/%s" % (volume_path, installer)
    if command is not None and installer == '':
        command = command.replace('${volume}', volume_path).encode("utf-8")
        command = shlex.split(command)
        pipes = subprocess.Popen(
            command,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = pipes.communicate()
        if pipes.returncode == 1:
            print stdout
            print stderr
            exit(1)
    if ".pkg" in installer:
        pkg_install(installer_path)
    if ".app" in installer:
        applications_path = "/Applications/%s" % installer.rsplit('/', 1)[-1]
        if os.path.exists(applications_path):
            shutil.rmtree(applications_path)
        shutil.copytree(installer_path, applications_path)
        # current_user - the name of the user running the script. Apple suggests using
        # both methods.
        # uid - the UID of the user running the script
        # gid - the GID of the group "admin" which the user account is expected to be a member of
        # users in macOS
        current_user = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]
        current_user = [current_user, ""][current_user in [u"loginwindow", None, u""]]
        uid = pwd.getpwnam(current_user).pw_uid
        gid = grp.getgrnam("admin").gr_gid
        os.chown(applications_path, uid, gid)
        for root, dirs, files in os.walk(applications_path):
            for d in dirs:
                os.chown(os.path.join(root, d), uid, gid)
            for f in files:
                os.chown(os.path.join(root, f), uid, gid)
    pipes = subprocess.Popen(["hdiutil", "detach", volume_path], stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)
    stdout, stderr = pipes.communicate()
    if pipes.returncode == 1:
        print stdout
        print stderr
        exit(1)


# the mobileconfig_install function installs configuration profiles
def mobileconfig_install(mobileconfig):
    pipes = subprocess.Popen(["/usr/bin/profiles", "-I", "-F", mobileconfig],
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = pipes.communicate()
    if pipes.returncode == 1:
        print stdout
        print stderr
        exit(1)


# the hash_file function accepts two arguments: the filename that you need to
# determine the SHA256 hash of and the expected hash it returns True or False.
def hash_file(filename, man_hash):
    if man_hash == "skip":
        print "NOTICE: Manifest file is instructing us to SKIP hashing %s." % filename
    else:
        hash_check = hashlib.sha256()
        with open(filename, 'rb') as downloaded_file:
            for chunk in iter(lambda: downloaded_file.read(4096), b""):
                hash_check.update(chunk)
        if hash_check.hexdigest() == man_hash:
            print "\rThe hash for %s match the manifest file" % filename
        else:
            print "WARNING: The the hash for %s is unexpected." % filename
            exit(1)
            
            
   # function that takes in the hash html file and checks for the line with the mac-us firefox SHA256 hash and returns the hash
 def check_string_contains(textfile, strline): 
    for line in textfile:
        if strline in line:
            linesplit = line.split()
            hash = linesplit[0]
            return hash
    return False

 
  # downloads the release SHA256 html page so I can use that file to search for the hash
  def hashpage(url):
    import urllib
    url = 'http://releases.mozilla.org/pub/firefox/releases/77.0.1/SHA256SUMS'
    urllib.urlretrieve(url, filename='hash.html')
    file = open("hash.html", "r") 
    return file


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


def main():
    # local_dir - the local directory the builder will use
    # org - the org that is hosting the build repository
    # repo - the rep that is hosting the build
    # default_branch - the default branch to build against if no --branch argument is specified
    # testing
    local_dir = "/var/tmp/dinobuildr"
    default_org = "mozilla"
    default_repo = "dinobuildr"
    default_branch = "master"
    default_manifest = "production_manifest.json"

    # this section parses argument(s) passed to this script
    # the --branch argument specified the branch that this script will build
    # against, which is useful for testing. the script will default to the master
    # branch if no argument is specified.
    parser = argparse.ArgumentParser()
    parser.add_argument("-b", "--branch",
                        help="The branch name to build against. Defaults to %s" % default_branch)
    parser.add_argument("-m", "--manifest",
                        help="The manifest to build against. Defaults to %s" % default_manifest)
    parser.add_argument("-r", "--repo",
                        help="The repo to build against. Defaults to %s" % default_repo)
    parser.add_argument("-o", "--org",
                        help="The org to build against. Defaults to %s" % default_org)

    args = parser.parse_args()

    if args.branch is None:
        branch = default_branch
    else:
        branch = args.branch

    if args.manifest is None:
        manifest = default_manifest
    else:
        manifest = args.manifest

    if args.repo is None:
        repo = default_repo
    else:
        repo = args.repo

    if args.org is None:
        org = default_org
    else:
        org = args.org

    # os.environ - an environment variable for the builder's local directory to be
    # passed on to shells scripts
    os.environ["DINOPATH"] = local_dir

    # lfs_url -  the generic LFS url structure that github uses
    # raw_url - the generic RAW url structure that github uses
    # manifest_url - the url of the manifest file
    # manifest_hash - the hash of the manifest file
    # manifest_file - the expected filepath of the manifest file
    lfs_url = "https://github.com/%s/%s.git/info/lfs/objects/batch" % (org, repo)
    raw_url = "https://raw.githubusercontent.com/%s/%s/%s/" % (org, repo, branch)
    manifest_url = "https://raw.githubusercontent.com/%s/%s/%s/%s" % (org, repo, branch, manifest)
    manifest_file = "%s/%s" % (local_dir, manifest)

    # check to see if user ran with sudo , since it's required

    if os.getuid() != 0:
        print "This script requires root to run, please try again with sudo."
        exit(1)

    # if the local directory doesn't exist, we make it.
    if not os.path.exists(local_dir):
        os.makedirs(local_dir)

    # download the manifest.json file.
    print "\nDownloading the manifest file and hash-checking it.\n"
    print manifest_url
    print manifest_file
    downloader(manifest_url, manifest_file)

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
            print "Installing:", item['item']
            pkg_install(local_path)
            print "\r"

        if item['type'] == "pkg":
            dl_url = item['url'].replace('${version}', item['version'])
            print "Downloading:", item['item']
            downloader(dl_url, local_path)
            hash_file(local_path, item['hash'])
            print "Installing:", item['item']
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
            # TODO: dmg-installer / dmg-advanced are not being checked to allow
            # for functionality that should be in a downloader function
            # in the manifest generator
            if item['url'] == '':
                print "No URL specified for %s" % item['item']
                break
            dl_url = item['url'].replace('${version}', item['version'])
            print "Downloading:", item['item']
            downloader(dl_url, local_path)
            hash_file(local_path, item['hash'])
            if item['dmg-installer'] != '':
                print "Installing:", item['dmg-installer']
            if item['dmg-advanced'] != '':
                print "Getting fancy and executing:", item['dmg-advanced']
            if item['dmg-installer'] == '' and item['dmg-advanced'] == '':
                print(("No installer or install command specified for %s."
                       "Assuming this is download only." % item['item']))
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
            print "File downloaded to:", local_path
            print "\r"

        if item['type'] == "file":
            if item['url'] == '':
                print "No URL specified for %s" % item['item']
                break
            dl_url = raw_url + item['url']
            print "Downloading:", item['item']
            downloader(dl_url, local_path)
            hash_file(local_path, item['hash'])
            print "File downloaded to:", local_path
            print "\r"

        if item['type'] == "mobileconfig":
            dl_url = raw_url + item['url']
            print "Downloading:", item['item']
            downloader(dl_url, local_path)
            hash_file(local_path, item['hash'])
            print "Applying Mobileconfig:", item['item']
            mobileconfig_install(local_path)
            print "\r"

    # delete the temporary directory we've been downloading packages into.
    print "Cleanup: Deleting %s" % local_dir
    shutil.rmtree(local_dir)

    print "Build complete!"


if __name__ == '__main__':
    main()
