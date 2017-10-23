import glob, os, hashlib, json, collections

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
            item_name = item.rstrip()
            #file_hash = hash_file((repo_path + item).rstrip())   
            manifest['packages'].append({
                'item': item_name,
                'hash': "",
                'version' : "",
                'dmg-installer' : "",
                'url' : "",
                'type' : ""
                })
print manifest 
orderfile.close()       

with open ('manifest.json', 'w') as outfile:
    json.dump(collections.OrderedDict(manifest), outfile, indent=4, sort_keys=False)
outfile.close()

manifest_hash = hash_file('manifest.json')
print "File created. The manifest has a hash of:", manifest_hash
