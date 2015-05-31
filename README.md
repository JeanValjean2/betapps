# Betapps
Very lean web layer to build your own iOS Beta Apps deployment platform

Clone the repository on your web server, inside a directory accessible by Apache, and prepare an IPA file that Xcode produced.

Your application is only one Bash command away from your beta-testers :


1) ./importIPA.sh <IPAFilePath> ./

2) Copy the URL contained in the output of the previous command and paste it into a browser.

3) Your application is available !
