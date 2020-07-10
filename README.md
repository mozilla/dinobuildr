# dinobuildr

## dinobuildr at Mozilla
The dinobuildr project is the current production macOS deployment and configuration tool at Mozilla. All Mozilla IT deployed Macs use this repo for initial system configuration via the following procedure:

1. Install and/or update to the latest revision of the current release of macOS using Apple sanctioned installation methods
2. Follow the macOS Setup Assistant to create a user account for the person that will be receiving the machine, and set some basic configurations
3. Utilize the `dinobuildr.sh` script to pull down a verified commit of the `dino_engine.py` configuration script and run it on behalf of the user account created in step 2

dinobuildr is intended to be a transparent, reliable, and auditable deployment solution. Anyone may inspect the automated components of our build, review what software is being deployed by default, and what configuration changes are made to a machine. Unlike most deployment and configuration management solutions dinobuildr is intended to be easy to understand, contribute to, and to audit. It does not rely on management binaries or other artifacts to work as it operates using Python 2.7 (which is built into macOS) and uses no external Python libraries. All configuration scripts exist in code that has been written and audited by Mozilla IT and all software packages come from trusted sources and are independently hashed by Mozilla IT. 

## Background 
dinobuildr is a macOS deployment utility developed by Mozilla IT. It provides a relatively flexible framework for deploying software and shell scripts to macOS clients running relatively new versions of macOS; relying on public-facing infrastructure such as Github and official vendor binary repositories that are exposed over the internet to deliver a consistent configuration. It is intended to be straightforward, simple, and is not feature rich - instead it offers a level of simplicity and transparency that may be useful in certain environments. 

dinobuildr relies on a JSON manifest to specify the actions the build will take (and it what order) as well as providing URLs and SHA256 hash values for all the scripts, files, and packages in the build. Updating a package is generally as straightforward as changing the version and hash attributes in the JSON manifest. The current version of dinobuildr supports hosting arbitrary files, scripts, pkg files, and dmg files in the following locations:

* **Arbitrary Files** - Github LFS
* **.pkg** - Github LFS, HTTP(S)/FTP
* **.dmg** - HTTP(S)/FTP
* **Bash Scripts** - Github
* **.mobileconfig Files** - Github

## Developing for dinobuildr
Because this repository is used as Mozilla's standard macOS deployment configuration, merges to the master branch require review from multiple administrators and commit access to this repository is restricted. In order to propose changes, contributors who are not admins in this repo may fork this repository to your own Github account, make changes and make a pull request of their forked branch against our master branch. Some additional requirements must be met and will be covered below:
### Contributing Guidelines
Contributing guidelines can be found [here](https://github.com/mozilla/dinobuildr/blob/master/CONTRIBUTING.md) and provide some general guidance for naming conventions and what we'd like to see in commits. As you can see from the commit history of this repo, we do not always follow these guidelines so don't worry if your commits are not perfect or branches are not named correctly, these guidelines are intended to be helpful and to eventually create a more uniform project. **Adherence to the [Community Participation Guidelines](https://www.mozilla.org/en-US/about/governance/policies/participation/) is not optional** and it is critical that every contributor read and follow the CPG.
### Git LFS
This repo makes use of [Git Large File Storage](https://git-lfs.github.com/). Set up LFS by installing the extension, which is easily accomplished with [Homebrew](https://brew.sh/).
```
git lfs install
```
File types that use LFS can be found in [.gitattribute](https://github.com/mozilla/dinobuildr/blob/master/resources/.gitattributes) files throughout the repo, but no additional configuration steps should be required to modify files that already exist in the repo.  
### Forking and Testing
[Fork the repo](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) by clicking the Fork button in the top right corner if your Github interface and develop as you would normally. You can test your branch before prosposing changes by using the following flags with `dinobuildr.sh`
```
--org -o
  [Defaults to: mozilla]
  The name of the "Organization", or account, to run dinobuildr from (usually your own Github account if you've forked
--repo -r
  [Defaults to: dinobuildr]
  The name of the repository to run dinobuildr from. 
  Keeping the default is usually fine, but if you forked to a different repository in your account you can specify it with this flag. 
--branch -b
  [Defaults to: master]
  The name of the branch to execute. Useful if you need to test a branch before proposing a merge to master.
--manifest -m
  [Defaults to: production_manifest.json]
  The name of the manifest in the org --> repo --> branch to use. Useful for testing alternate deployments. 
```
A common example of a test build for a forked repository would be:
```
sudo dinobuildr.sh --org luciusbono --branch upd8-firefox78
```
This would build my test machine from my fork (assuming it was a repo called `dinobuildr` in an account called `luciusbono`) and would build against my development branch called `upd8-firefox78`. 
Note that it's not required to specify the `--repo` if your fork is using the default repo name `dinobuildr`, nor is it necessary to specify a manifest if you're just working on the `production_manifest.json` default manifest. 
### flake8 and shellcheck
All pull requests require basic code quality checks to pass. This is currently handled via [travis-ci](https://github.com/mozilla/dinobuildr/blob/master/.travis.yml) and it is important to run the following checks on your branch before you propose a pull request to master.
#### shellcheck
Shellcheck is a BASH linter. Run it against any BASH scripts you change / create before creating a pull request and follow any guidance it suggests. 

Install [shellcheck](https://github.com/koalaman/shellcheck) with:
```
brew install shellcheck
```
Then execute it against the script(s) you've changed:
```
shellcheck [path-to-script]
```
You can also execute it recursively against all the scripts in your `dinobuildr` working directory:
```
find [path-to-dinobuildr-dir] -type f -exec grep -Eq '^#!(.*/|.*env +)(sh|bash|ksh)' {} \; \ | xargs shellcheck
```
#### flake8
flake8 is a Python linter. We run it in it's default configuration with a single exception: 100 character line limits. Run it against any Python scripts you change / create before creating a pull request and follow any guidance it suggests.

Install [flake8](https://pypi.org/project/flake8/)
```
pip install flake8
```
Then execute it against the script(s) you've changed:
```
flake8 --max-line-length 100 [path-to-script]
```
You can also execute it recursively against all the scripts in your `dinobuildr` working directory:
```
flake8 --max-line-length 100 [path-to-dinobuildr-dir]
```
