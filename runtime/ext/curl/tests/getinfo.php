<?

$ch = curl_init();

curl_setopt($ch, CURLOPT_URL, "http://www.example.com");
curl_exec($ch);
$a = curl_getinfo($ch);

// times are different so it miffs the results
$a['total_time'] = 'xxx';
$a['namelookup_time'] = 'xxx';
$a['connect_time'] = 'xxx';
$a['pretransfer_time'] = 'xxx';
$a['starttransfer_time'] = 'xxx';
$a['speed_upload'] = 'xxx';
$a['speed_download'] = 'xxx';

print_r($a);

echo curl_getinfo($ch, CURLINFO_HTTP_CODE);

curl_close($ch);

?>

