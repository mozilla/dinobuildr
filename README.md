# dinobuildr

## dinobuildr at Mozilla
The dinobuildr project is the current production macOS deployment and configuration tool at Mozilla. All Mozilla IT deployed Macs use this repo for initial system configuration via the following procedure:

1. Install the latest supported version of macOS via official approved Apple install media, using the operating system shipped from the factory if possible
2. Follow the macOS Setup Assistant to create a user account for the person that will be receiving the machine
3. Utilize the 'dinobuildr.sh' script to pull down a verified commit of the `dino_engine.py` configuration script and run it on behalf of the user account created in step 2
4. Enable Filevault and ensure that the password for the user account is set to something sufficiently random and complicated and hand over the machine to the person who requested it

dinobuildr is intended to be a transparent, reliable, and auditable deployment solution. Anyone may inspect the automated components of our build, review what software is being deployed by default, and what configuration changes are made to a machine. Unlike most deployment and configuration management solutions dinobuildr is intended to be simple, easy to understand, contribute to, and audit. It does not rely on any management binaries or any other artifacts to work as it is able to do everything using Python 2.7 that is built into macOS and uses no external Python libraries. All configuration scripts exist in code that has been written and audited by Mozilla IT and all software packages come from trusted sources and are independently hashed by Mozilla IT. 

## Background 
dinobuildr is a macOS deployment utility developed by Mozilla IT. It provides a relatively flexible framework for deploying software and shell scripts to macOS clients running relatively new versions of macOS; relying on public-facing infrastructure such as Github and official vendor binary repositories that are exposed over the internet to deliver a consistent configuration. It is intended to be straightforward, simple, and is not feature rich - instead it offers a level of simplicity and transparency that may be useful in certain environments. 

dinobuildr relies on a JSON manifest to specify the actions the build will take (and it what order) as well as providing URLs and SHA256 hash values for all the scripts, files, and packages in the build. Updating a package is generally as straightforward as changing the version and hash attributes in the JSON manifest. The current version of dinobuildr supports hosting arbitrary files, scripts, pkg files, and dmg files in the following locations:

* **Arbitrary Files** - Github LFS
* **.pkg** - Github LFS, HTTP(S)/FTP
* **.dmg** - HTTP(S)/FTP
* **Bash Scripts** - Github
* **.mobileconfig Files** - Github
