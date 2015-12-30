#!/bin/bash

###Les droits des dossiers/sous-dossiers et fichiers ne sont pas correctement réglés.
###Dépendances :
# * plistutil : (Compilé depuis : https://github.com/libimobiledevice/libplist)
# * xml2
# * php (+ deux scripts personnels : parsePList.php et basicTemplate.php)
# * unzip

#http://help.apple.com/deployment/ios/#/apda0e3426d7
#http://blog.octo.com/en/automating-over-the-air-deployment-for-iphone/

[[ $# -lt 3 ]] && echo "Ce script attend 3 paramètres : le chemin vers un fichier IPA, le dossier local dans lequel déposer le produit déployable et l'URL correspondant à la racine du site de déploiement." && exit 1;

rm -rf tmp/
mkdir tmp
IPA=$1
IPAFileName=`basename "$IPA"`
IPASubDirName=`basename "$IPA" .ipa | tr A-Z a-z`
IPASubDirName=`basename "$IPA" .ipa`
RootDir=`basename "$2"`

#2015-12-30 : on prend en compte n'importe quelle URL de dépôt en nettoyant au mieux le paramètre passé sur la CLI
T=$3
#trim
T=`echo $T | sed 's/^[ \t]*//;s/[ \t]*$//'`
#Pas besoin du préfixe
T=`echo $T | sed 's/https\?:\/\///'`
#Virer le / final éventuel
T=`echo $T | sed 's/\/*$//'`
RootURL="https://$T"

echo "Traitement de $IPA..."
sleep 1
unzip -q "$IPA" -d tmp/ "Payload/$IPASubDirName.app/Info.plist" "Payload/$IPASubDirName.app/embedded.mobileprovision"
sleep 1

#2015-09-21 : Xcode 7 envoie ses plist en texte et non plus en .plist binaire.
file "tmp/Payload/$IPASubDirName.app/Info.plist" | grep -i text > /dev/null
IsText=$?

#On commence par parser le fichier Info.plist qui contient certaines informations sur l'IPA qui vont permettre de construire à 90% les fichiers permettant d'installer l'application
ParseInfo="plistutil -i"
[[ $IsText == 0 ]] && ParseInfo="cat";
BUNDLE_IDENTIFIER=`$ParseInfo "tmp/Payload/$IPASubDirName.app/Info.plist" | xml2 | grep -A 1 CFBundleIdentifier | tail -n1 | cut -d '=' -f 2`
#echo $BUNDLE_IDENTIFIER
BUNDLE_VERSION=`$ParseInfo "tmp/Payload/$IPASubDirName.app/Info.plist" | xml2 | grep -A 1 CFBundleVersion | tail -n1 | cut -d '=' -f 2`
BUNDLE_SHORTVERSION=`$ParseInfo "tmp/Payload/$IPASubDirName.app/Info.plist" | xml2 | grep -A 1 CFBundleShortVersionString | tail -n1 | cut -d '=' -f 2`
BUNDLE_TITLE=`$ParseInfo "tmp/Payload/$IPASubDirName.app/Info.plist" | xml2 | grep -A 1 CFBundleDisplayName | tail -n1 | cut -d '=' -f 2`
#echo $BUNDLE_TITLE
BUNDLE_NAME=`$ParseInfo "tmp/Payload/$IPASubDirName.app/Info.plist" | xml2 | grep -A 1 CFBundleName | tail -n1 | cut -d '=' -f 2`
#echo $BUNDLE_NAME
MINIMUM_OSVERSION=`$ParseInfo "tmp/Payload/$IPASubDirName.app/Info.plist" | xml2 | grep -A 1 MinimumOSVersion | tail -n1 | cut -d '=' -f 2`
ICON_FILENAME=`$ParseInfo "tmp/Payload/$IPASubDirName.app/Info.plist" | xml2 | grep -A 1 CFBundleIconFile | tail -n1 | cut -d '=' -f 2`

[[ ${#BUNDLE_TITLE} == 0 ]] && BUNDLE_TITLE=$BUNDLE_NAME;

unzip -q "$IPA" -d tmp/ "Payload/$IPASubDirName.app/$ICON_FILENAME*"
ICON_PATH=`find tmp/Payload/ -name "$ICON_FILENAME*" | tail -n1`
[[ ! -f $ICON_PATH ]] && echo "Pas d'icône dans l'application ? Nom : $ICON_FILENAME" && exit 1;

#Le nom de l'icône peut avoir un suffixe @3x ou autre. Il faut donc utiliser celui de Info.plist pour extraire le fichier du ZIP, mais ce dernier a un nom avec le bon suffixe.
ICON_FILENAME=`basename "$ICON_PATH"`
#On va construire les différents chemins et URL en vérifiant qu'un dossier n'existe pas déjà. Auquel cas, on ajoute un numéro qui s'incrémente automatiquement.
RelativeDir=$BUNDLE_IDENTIFIER/$BUNDLE_SHORTVERSION-$BUNDLE_VERSION
Cnt="1"
while [[ -d $RootDir/$RelativeDir ]]; do
	RelativeDir=$BUNDLE_IDENTIFIER/$BUNDLE_SHORTVERSION-$BUNDLE_VERSION-$Cnt
	((Cnt++))
done

AppDir=$RootDir/$RelativeDir
BUNDLE_URL="$RootURL/$RootDir/$RelativeDir/$IPAFileName"
MANIFEST_PLIST_URL="$RootURL/$RootDir/$RelativeDir/manifest.plist"
TestersURL="$RootURL/$RootDir/$RelativeDir/"
APPICON_URL="$RootURL/$RootDir/$RelativeDir/$ICON_FILENAME"

#On poursuit en analysant le fichier embedded.mobileprovision pour avoir les dernières infos utiles (nom de l'équipe, les UUIDs pouvant installer l'IPA etc)
#Pour analyser ce fichier (embedded.mobileprovision) il faut tout d'abord le nettoyer : l'entête et le pied de fichier sont en binaire et n'ont rien à voir avec le document XML constituant la PLIST qui nous intéresse.
cat "tmp/Payload/$IPASubDirName.app/embedded.mobileprovision" | php -r '$C=file_get_contents("php://stdin"); $C=substr($C, strpos($C, "<?xml")); $C=substr($C, 0, strpos($C, "</plist>")+8); echo "$C\n";' > tmp/embedded.mobileprovision.plist
TMPFILENAME=tmp/embedded.mobileprovision.plist
#APPIDNAME=`cat $TMPFILENAME | xml2 | grep -A 1 AppIDName | tail -n1 | cut -d '=' -f 2`
APPIDNAME=$BUNDLE_NAME
APPCREATIONDATE=`cat $TMPFILENAME | xml2 | grep -A 1 CreationDate | tail -n1 | cut -d '=' -f 2`
ENTITLEMENTS=`cat $TMPFILENAME | php parsePList.php Entitlements`
NAME=`cat $TMPFILENAME | xml2 | grep -A 1 Name | tail -n1 | cut -d '=' -f 2`
PROVISIONEDDEVICES=`cat $TMPFILENAME | php parsePList.php ProvisionedDevices`
TEAMNAME=`cat $TMPFILENAME | xml2 | grep -A 1 TeamName | tail -n1 | cut -d '=' -f 2`

#On construit le fichier manifest.plist
#Note : je suis obligé de répéter les variables sur la ligne de commande parce que Bash échappe les espaces apparemment si je les factorise dans une variable et les arguments sont en bazar
php basicTemplate.php MANIFEST_PLIST_URL "$MANIFEST_PLIST_URL" ICON_FILENAME "$ICON_FILENAME" APP_PUBLISHER "$NAME" BUNDLE_IDENTIFIER "$BUNDLE_IDENTIFIER" BUNDLE_SHORTVERSION "$BUNDLE_SHORTVERSION" BUNDLE_VERSION "$BUNDLE_VERSION" BUNDLE_TITLE "$BUNDLE_TITLE" IPA_URL "$BUNDLE_URL" APP_NAME "$APPIDNAME" APPICON_URL "$APPICON_URL" MINIMUM_OSVERSION "$MINIMUM_OSVERSION" rsc/manifest.plist.tpl > tmp/manifest.plist
php basicTemplate.php MANIFEST_PLIST_URL "$MANIFEST_PLIST_URL" ICON_FILENAME "$ICON_FILENAME" APP_PUBLISHER "$NAME" BUNDLE_IDENTIFIER "$BUNDLE_IDENTIFIER" BUNDLE_SHORTVERSION "$BUNDLE_SHORTVERSION" BUNDLE_VERSION "$BUNDLE_VERSION" BUNDLE_TITLE "$BUNDLE_TITLE" IPA_URL "$BUNDLE_URL" APP_NAME "$APPIDNAME" APPICON_URL "$APPICON_URL" MINIMUM_OSVERSION "$MINIMUM_OSVERSION" PROVISIONEDDEVICES "$PROVISIONEDDEVICES" ENTITLEMENTS "$ENTITLEMENTS" rsc/index.html.tpl > tmp/index.html
echo "Les fichiers manifest.plist et index.html ont été générés"

mkdir -p $AppDir
sleep 1
cp "$IPA" $AppDir/
cp -f "$ICON_PATH" $AppDir/
mv -f tmp/manifest.plist $AppDir/
mv -f tmp/index.html $AppDir/

echo "Adresse à transmettre aux testeurs : $TestersURL"

#Stocke le fichier en les préfixant avec le timestamp courant (i.e. celui de l'upload en gros)
mkdir -p uploaded/
mv -n "$IPA" "uploaded/`date +%s`-$IPAFileName"
