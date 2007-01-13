<?

$test = 'some string';

$test['user'] = 'bleh';
$test['db'] = 'blah';

var_dump($test);

$test = '';

$test['user'] = 'bleh';
$test['db'] = 'blah';

var_dump($test);

$test = 'some string';

$test[0] = 'blah';
$test[1] = 'c';

var_dump($test);

$test = 'some string';

$test[0] = 'blah';
$test[1] = 'c';

var_dump($test);

$test = '';

$test[0] = 'blah';
$test[1] = 'c';

var_dump($test);



?>