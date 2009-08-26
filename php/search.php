<?php

//include('input filter/class.inputfilter.php');//Need to get this again

$separator = $_GET['operator'];
$query = json_decode(stripslashes($_GET['query']), YES);

//$myFilter = new InputFilter();

$sql = "SELECT * FROM HerpWeb2 WHERE ";

//echo $sql;

//echo count($query);
for($i=0; $i<count($query); $i++)
{
	//echo $i;
	$type = $query[$i][0];
	//echo "type is: ".$type;
	$operator = $query[$i][1];
	$value = $query[$i][2];//$myFilter.process($query[$i][2]);//Clean this up
	
	if($i != 0)
	{
		if($separator=="or")
			$sql .=	" || ";
		else
			$sql .= " && ";
	}
	
	switch($operator)
	{
		case "is":
			$sql .= $type." = '".$value."'";
			break;
		case "is not":
			$sql .= $type." != '".$value."'";
			break;
		case "contains":
			$sql .= $type." LIKE '%".$value."%'";
			break;
		case "does not contain":
			$sql .= $type." NOT LIKE '%".$value."%'";
			break;
		case "is between":
			$values = split("-", $value);
			$sql .= $type." >= ".$values[0]." && ".$type." <= ".$values[1];
			break;
		case "is not between":
			$values = split("-", $value);
			$sql .= $type." <= ".$values[0]." && ".$type." >= ".$values[1];
			break;
		case "is or after":
			$sql .= $type." >= ".$value;
			break;
		case "is or before":
			$sql .= $type." <= ".$value;
			break;
		default:
			$error = "not a standard operator";
			break;
	}
	
	if($error)
	{
		//do something
	}
}

$sql .= " ORDER BY Museum, CatNo";


$link = mysql_connect('localhost', 'root', 'root');
mysql_select_db("CAS") or die(mysql_error());

$result = mysql_query($sql);
if (!$result) {
    die('Invalid query: ' . mysql_error());
}

/*toro.calacademy.org HerpWeb2 iusr_tango idbuser herpcat
$link = msql_connect('toro.calacademy.org', 'iusr_tango', 'idbuser') or die(msql_error());
msql_select_db('HerpWeb2', $link) or die('Could not select database');
$result = msql_query($query, $link) or die('Query failed : ' . msql_error());*/

$data = array();
while ($row = mysql_fetch_array($result, MYSQL_ASSOC))//$row = msql_fetch_array($result, MSQL_ASSOC)//
{
	if(array_search($row, $data) === false)
	{
		array_push($data, $row);
	}
}

echo json_encode($data);
//mysql_free_result($result);

?>