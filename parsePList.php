<?php
//Parseur de fichiers .plist, permettant notamment d'extraire les valeurs de type "array" et "dict" d'un fichier embedded.mobileprovision

function	getXMLArray(&$o)		{
	$ParsedArray = Array();
	foreach($o as $ItemIdx=>$Item)			$ParsedArray[] = (string)$Item;
	return $ParsedArray;
}

function 	parseXMLDict(&$o, $keyToFilter="", $level=0)		{
	$Parsed = Array();
	$NextItemKey = false;
	foreach ($o as $TagName=>$Child)		{
		if ($NextItemKey !== false)		{
			if ($TagName == "array")		$Parsed[$NextItemKey] = getXMLArray($Child);
			else	if ($TagName == "dict")			$Parsed[$NextItemKey] = parseXMLDict($Child, "", $level+1);
			else	if ($TagName == "false")		$Parsed[$NextItemKey] = false;
			else	if ($TagName == "true")			$Parsed[$NextItemKey] = true;
			else	if ($TagName == "string")		$Parsed[$NextItemKey] = (string) $Child;
			else	echo "On doit extraire un $TagName et la fonction correspondante n'existe pas !\n";
			$NextItemKey = false;
			continue;
		}
		if ($TagName == "key")		{
			$KeyName = (string)$Child;
			if ($level == 0 && strlen($keyToFilter) && $KeyName == $keyToFilter)		$NextItemKey = $KeyName;
			else if ($level == 1)	$NextItemKey = $KeyName;
			//if ($NextItemKey !== false) 	echo "$TagName : $KeyName\n";
		}
	}
	return $Parsed;
}

	$X=file_get_contents("php://stdin");
	$XML=simplexml_load_string($X);
	$KeyToFilter = $_SERVER["argv"][1];		//Si on ne passe aucun paramètre le fichier plist devrait être parsé en totalité
	$Parsed = parseXMLDict($XML->dict->children(), $KeyToFilter);
	echo serialize($Parsed);
?>
