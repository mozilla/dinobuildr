# dinobuildr

## dinobuildr at Mozilla
This repo includes the current production macOS deployment and configuration at Mozilla. All Mozilla IT deployed Macs will use this repo to configure Macs using the following procedure:

1. Install the latest supported version of macOS via official approved Apple install media, including the operating system shipped from the factory if possible
2. Walk through the macOS Setup Assistant and create a user account for the person that will be receiving the machine
3. Pull down a verified commit of the `config.py` configuration script and execute it on behalf of the user account created in step 2
4. Enable Filevault, ensure that the password for the new user account is set to something sufficiently random and complicated and hand over the machine to the person who requested it

dinobuildr intends to be a transparent, reliable and auditable deployment solution. Anyone may inspect the automated components of our build, inspect what software Mozilla IT is deploying by default and what configuration changes are made to a machine. Unlike most deployment and configuration management solutions, dinobuildr is intended to be simple and easy to contribute to, audit and understand and does not rely on any management binaries or any other artifacts to work, as it is able to do everything using the version of Python that ships with macOS and uses no external python libraries. All configuration scripts exist in code and have been written and audited by Mozilla IT and all software packages come from trusted sources and are independently hashed by Mozilla IT. 

## Background 
dinobuildr is a macOS deployment utility developed by Mozilla IT. It provides a relatively flexible framework for deploying software and shell scripts to macOS clients running relatively new versions of macOS, relying on public-facing infrastructure such as Github and official vendor binary repositories that are exposed over the internet to deliver a consistent configuration. It is intended to be straightforward and simple, and is not feature rich - but offers a level of simplicity and transparency that may be useful in certain environments. 

dinobuildr relies on a JSON manifest to specify the actions the build will take (and it what order) as well as providing URLs and SHA256 hash values for all the scripts, files and packages in the build. Updating a package is generally as straightforward as changing the version and hash attributes in the JSON manifest, and a manifest generator called `create_manifest.py` is provided to make this process more straightforward. The current version of dinobuildr supports hosting arbitrary files, scripts, pkg and dmg files in the following locations:

* **Arbitrary Files** - Github LFS
* **.pkg** - Github LFS, HTTP(S)/FTP
* **.dmg** - HTTP(S)/FTP
* **Bash Scripts** - Github
* **.mobileconfig Files** - Github
