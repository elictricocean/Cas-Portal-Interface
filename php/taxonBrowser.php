<?php
	$types = array("class", "order", "family", "genus", "sp");

	$contentType = $_GET['type'];
	$value = $_GET['value'];
	
	$newType = "";
	
	
	if($contentType != "" && $value == "")
	{
		if($contentType == "sp") $contentType = "genus, sp";
		$query = "SELECT ". $contentType ." FROM HerpWeb2 ORDER BY ". $contentType;
		$newType = $contentType;
	}
	else
	{
		$newType = $types[array_search($contentType, $types)+1];
		$query = "SELECT ". $newType ." FROM HerpWeb2 WHERE ". $contentType ." = '". $value ."' ORDER BY ". $newType;
		//if($newType == "species")
		//{
			//echo $query;
		//}
	}
	
	//echo $query;
	
	//SQL stuff
	mysql_connect('localhost', 'root', 'root');
	mysql_select_db("CAS") or die(mysql_error());
	//toro.calacademy.org HerpWeb2 iusr_tango idbuser herpcat
	//$link = msql_connect('toro.calacademy.org', 'iusr_tango', 'idbuser') or die(msql_error());
    //echo "test";
    //msql_select_db('HerpWeb2', $link) or die('Could not select database');
    
    //$result = msql_query($query, $link) or die('Query failed : ' . msql_error());
    //echo $result;
	$result = mysql_query($query);
	$data = array();
	while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {//$row = msql_fetch_array($result, MSQL_ASSOC)){//
		//echo $row;
		if($contentType == "genus, sp")
		{
			if(array_search($row["genus"]." ".$row["sp"], $data) === false)
			{
				array_push($data, $row["genus"]." ".$row["sp"]);
			}
		}
		else if(array_search($row[$newType], $data) === false)
		{
			array_push($data, $row[$newType]);
		}
	}
	//echo "got through";
	//Return JSON
	echo json_encode($data);
	
	//Release result
	mysql_free_result($result);
?>