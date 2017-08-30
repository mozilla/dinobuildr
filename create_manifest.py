import glob
import os
import hashlib
import json

repo_path = 'repo/*.pkg'
manifest = {}
manifest['packages'] = []

def hash_file(filename):
    hash = hashlib.sha256()
    with open (filename, 'rb') as file:
        for chunk in iter(lambda: file.read(4096), b""):
            hash.update(chunk)
    return hash.hexdigest() 

for file in glob.glob(repo_path):
    file_hash = hash_file(file)   
    file_name = os.path.basename(file)
    print (file_name)
    print (file_hash)
    manifest['packages'].append({
            'name': file_name,
            'path': file,
            'hash': file_hash
            })

    with open ('manifest.json', 'w') as outfile:
        json.dump(manifest, outfile)


