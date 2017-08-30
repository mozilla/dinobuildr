import subprocess, glob

local_repo = 'repo'

def pkg_install(package):
    pipes = subprocess.Popen(["sudo","installer","-pkg",package,"-target","/"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode

def script_exec(script):
    pipes = subprocess.Popen(["/bin/bash","-c",script], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = pipes.communicate()
    print out.decode('utf-8'), err.decode('utf-8'), pipes.returncode
    
for file in glob.glob("repo/*.pkg"):
    print "Installing: ",file
    pkg_install(file)

for file in glob.glob("repo/*.sh"):
    print "Executing: ",file
    script_exec(file)
