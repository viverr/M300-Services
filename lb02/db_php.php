<?php
$con = mysqli_connect("localhost","admin","admin","DB-LB02");
// Check connection
if (mysqli_connect_errno())
{
echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

$result = mysqli_query($con,"SELECT Beschreibung FROM TESTWERT");

echo "<table border='1'>
<tr>
<th>TESTWERT:</th>
</tr>";

while($row = mysqli_fetch_array($result))
{
echo "<tr>";
echo "<td>" . $row['FirstName'] . "</td>";
echo "</tr>";
}
echo "</table>";

mysqli_close($con);
?>