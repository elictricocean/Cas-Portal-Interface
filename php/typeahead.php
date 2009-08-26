<?php
	$field = $_GET['field'];
	$value = $_GET['value'];
	//$filters = json_decode($_GET['filters']);
	
	$query = "SELECT ". strtolower($field) ." FROM HerpWeb2 WHERE ". strtolower($field) ." LIKE '%". $value ."%' LIMIT 15";
	
	//SQL stuff
	mysql_connect('localhost', 'root', 'root');
	mysql_select_db("CAS") or die(mysql_error());
	$result = mysql_query($query);
	$data = array();
	while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
		if(array_search($row[strtolower($field)], $data) === false)
		{
			array_push($data, $row[strtolower($field)]);
		}
	}
	
	//Return JSON
	echo json_encode($data);
	
	//Release result
	mysql_free_result($result);
?>