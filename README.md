# Betapps
Very lean web layer to build your own iOS Beta Apps deployment platform

Clone the repository on your web server, inside a directory accessible by Apache, and prepare an IPA file that Xcode produced.

Your application is only one Bash command away from your beta-testers :


1) ./importIPA.sh *IPAFilePath* *InstallationSubDir* *DeployURL*

This command will process your IPA located at *IPAFilePath* and copy the result into the local sub-directory *InstallationSubDir*, corresponding to the URL https://*DeployURL*/*InstallationSubDir*/.

2) Copy the URL contained in the output of the previous command and paste it into a browser.

3) Your application can be installed seamlessly ! (provided the UDID of the device is included into the provisioning profiles included in the app...)

----------------

The step 1 actually create a subdir and multiples files :

* an **icon** extracted from the *IPA* file
* a **manifest.plist** file generated from the *Info.plist* file inside the *IPA*. This file is crucial for the installation : it's the first file downloaded by the device, through *HTTPS*.
* the actual **IPA** file. Yes.
* an **HTML** file, which is just a shell for the link to the aformentioned *manifest.plist* file.
