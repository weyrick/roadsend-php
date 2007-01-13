<?


// strstr
$email = 'user@example.com';
print strstr($email, '@');
print strstr($email.'@example.com','@');
print strstr($email,'---');
print strstr($email, 'USER');
print strstr($email, 'cOm');
print strstr($email,'amp');

print strchr($email, 'cOm');
print strchr($email,'amp');

// stristr
$email = 'user@example.com';
print stristr($email, '@');
print stristr($email.'@example.com','@');
print stristr($email,'---');
print stristr($email, 'USER');
print stristr($email, 'cOm');
print stristr($email,'amp');



?>