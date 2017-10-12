# dinobuildr
A dev repository for a macOS configurator. Will live in Mozilla-IT after development is complete and RRA has been performed. 

## Overview
Dinobuildr is intended to replace the existing Casper Imaging infrastructure for configuring macOS machines for new employees at Mozilla. The dinobuildr build script (`config.py`) is intended to be downloaded to an endpoint via a `curl` on to a machine that has just completed the macOS Setup Assistant. This machine can either be "fresh" from Apple, or newly rebuilt using official Apple installation media. 

The configuration script should be downloaded via the last "verified" commit that the repo owners bless. Not trusting the master branch explicitly, and instead relying on an immutable hash is intended to decrease the likelihood that the build script could be compromised without anyone taking note. Google's URL shortening service will be used to make the direct links to the commit of the build script easy for users and techs to input manually, and the verified links will be published internally. 

The build script pulls down a manifest file (from master), verifies the manifest file's sha256 hash against an expected value and then begins to download and install any script or pkg files specified in the manifest file. Each script or package is hash-verifified before installation, and the script leverages the github API to pull scripts and large binaries (packages) directly from the repo - eliminating `git` as a pre-requisite. 

Upon completion, the script will delete all scripts and packages, the manifest file and itself - leaving only a log file and intentional build artifacts (configuration changes, installed applications, etc). 

**TODO: Logging feature not implemented**

Dinobuildr is intended to provide a more open, transparent, and flexible initial configuration environment. It does not rely on any in-office infrastructure, and in it's final form will exist on public Github. This allows techs or users to configure new MacOS endpoints with relative confidence as long as a working internet connection is present. Dinobuildr also allows Mozilla to move away from monolithic system images, which require constant maintenance as new operating system versions release. We will rely on Apple's own operating system deployment mechanisms and configure the machines to our standards as a separate layer. 

Eventually, we would also like to use dinobuildr as a means to move away from maintaining binary packages in our build, and instead have the dinobuildr pull down the latest trusted version of an application from the vendor directly. This feature has not been implemented yet, but initial testing suggests that `homebrew` may be a good mechanism to use to achieve this goal. 

## Recommended Usage

1. Launch `Terminal.app`
2. `cd` to the Desktop of the active user (e.g. `cd ~/Desktop`)
3. Download the latest "blessed" `config.py` script via curl. (e.g. `curl -o config.py https://goo.gl/xovL93`)
4. Execute the script (e.g. `python config.py`)

![img](https://singularityplaytime.files.wordpress.com/2014/08/dinosaurs-lasers.jpg)
