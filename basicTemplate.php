<?php
//Moteur simplifié de "template" afin de fournir un service que Bash a du mal à faire de manière élégante.

function	isSerialized(&$val)		{		return substr($val, 0, 4) == "a:1:";		}

$Vars = Array();
$FilePathToProcess = "";
$i = 1;
while ($i<$_SERVER["argc"])		{
	$Arg = trim($_SERVER["argv"][$i]);
	if ($Arg[0] == "'" || $Arg[0] == "\"")		$Arg = substr($Arg, 1, -1);
	if (isSerialized($Arg))			$Arg = unserialize($Arg);
	if ($i == $_SERVER["argc"] - 1)		{
		$FilePathToProcess = $Arg;
		break;
	}
	if ($i%2 == 1)		$NextVarName = $Arg;
	else				$Vars[$NextVarName] = $Arg;
	$i++;
}

if (file_exists($FilePathToProcess) === false)		die("Le fichier $FilePathToProcess n'existe pas.\n");
$C = file_get_contents($FilePathToProcess);
foreach($Vars as $Name=>$Val)		{
	if (is_array($Val))		{
		$NewVal = "";
		$Keys = array_keys($Val);
		foreach($Val[$Keys[0]] as $Idx=>$Field)		{
			if (is_numeric($Idx) === false)		$NewVal .= "$Idx : ";
			$NewVal .= $Field."<br/>\n";
		}
		$Val = $NewVal;
	}
	$C = str_replace("%".$Name."%", $Val, $C);
}
echo $C;
?>
