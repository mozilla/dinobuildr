# dinobuildr

## Overview
dinobuildr is a MacOS deployment utility developed by Mozilla IT. It provides a relatively flexible framework for deploying software and shell scripts to MacOS clients running relatively new versions of MacOS, relying on public-facing infrastructure such as Github and official vendor binary repositories that are exposed over the internet to deliver a consistent configuration. It is intended to be straightforward and simple, and is not feature rich - but offers a level of simplicity and transparency that may be useful in certain environments. 

dinobuildr relies on a JSON manifest to specify the actions the build will take (and it what order) as well as providing URLs and SHA256 hash values for all the scripts, files and packages in the build. Updating a package is generally as straightforward as changing the version and hash attributes in the JSON manifest, and a manifest generator called `create_manifest.py` is provided to make this process more straightforward. The current version of dinobuildr supports hosting arbitrary files, scripts, pkg and dmg files in the following locations:

* **Arbitrary Files** - Github LFS
* **.pkg** - Github LFS, HTTP(S)/FTP
* **.dmg** - HTTP(S)/FTP
* **Bash Scripts** - Github
