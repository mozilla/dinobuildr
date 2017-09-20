import glob, os, hashlib, json

repo_path = 'repo/'
remote_path = 'https://api.github.com/repos/mozilla/dinobuildr/contents/'
manifest = {}
manifest['packages'] = []

def hash_file(filename):
    hash = hashlib.sha256()
    with open (filename, 'rb') as file:
        for chunk in iter(lambda: file.read(4096), b""):
            hash.update(chunk)
    return hash.hexdigest() 

print "Creating a manifest.json..."

if os.path.isfile("order.txt"):
    with open ('order.txt', 'r') as orderfile:
        for item in orderfile:
            file_hash = hash_file((repo_path + item).rstrip())   
            file_name = os.path.basename((repo_path + item).rstrip())
            manifest['packages'].append({
                'name': file_name,
                'local_path': repo_path + file_name,
                'hash': file_hash
                })

orderfile.close()       

with open ('manifest.json', 'w') as outfile:
    json.dump(manifest, outfile, indent=4)
outfile.close()

manifest_hash = hash_file('manifest.json')
print "File created. The manifest has a hash of:", manifest_hash
