<?

$small = "ABCDEFGHIJKLMNOPQRSTUVQXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}";
for ($i=65; $i<126; $i++) {
  echo str_replace(chr($i),'1',$small);
}

for ($i=65; $i<126; $i++) {
  echo str_replace(chr($i),'foo',$small);
}

for ($i=65; $i<126; $i++) {
  echo str_replace(chr($i),'fooooooooooooooooooooooooooooooooooooooooooooooooooooo',$small);
}

$big =<<<FOO
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nam orci. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec nisl. Aenean vitae sapien. Maecenas consequat dui quis turpis. Sed convallis est ac tellus. Duis tristique. Nulla vitae neque sit amet mauris fringilla luctus. Aliquam nonummy consectetuer augue. Etiam dictum tristique diam. Fusce vel urna. Integer vitae tellus. Etiam semper dui sed nulla. Morbi pellentesque. Quisque pretium, nisi sit amet pretium dapibus, ante dolor sollicitudin tellus, a dapibus sapien orci eget lectus. Sed suscipit, ligula eget ultricies cursus, nisi libero consequat massa, vel tempus dui justo id diam. Proin suscipit sapien vel elit.

Quisque pharetra, tellus eget ornare lobortis, mauris ligula aliquet neque, sit amet laoreet leo purus eu lacus. Cras rutrum sapien ac augue. Curabitur tempor. In vestibulum, pede nec rutrum viverra, augue purus ultricies mauris, eget euismod nulla odio ornare felis. Morbi sodales mollis eros. Vivamus arcu lacus, interdum nec, sollicitudin at, tempor nec, urna. In sit amet magna. Vivamus nisi. Nulla diam leo, vehicula nec, adipiscing id, interdum non, quam. Curabitur suscipit libero non dolor. Vestibulum id lacus. Maecenas porta. Nunc semper varius pede. Duis luctus risus a nisi. Nunc non justo ultrices elit gravida mollis. Suspendisse tincidunt condimentum ante. Aenean eget sapien.

Suspendisse ut est at magna adipiscing commodo. Vestibulum fermentum commodo mauris. Vivamus pulvinar ligula quis nulla. Quisque adipiscing elit at sem auctor aliquet. Donec tellus erat, aliquam vel, gravida vel, dapibus vitae, quam. Mauris ornare. Praesent scelerisque dolor non diam. Vestibulum vel ante non metus ullamcorper dictum. In nisl neque, ultrices sodales, aliquam tempor, commodo at, massa. Aenean rutrum orci non est. Mauris hendrerit. In mollis, pede vel euismod interdum, velit metus sodales urna, sit amet elementum risus pede vel eros. In condimentum adipiscing pede. Sed odio. Curabitur adipiscing odio in dolor. Maecenas fermentum mi sed enim. Aenean ipsum. Cras semper molestie odio.

Nulla in felis. Duis malesuada libero vestibulum justo. Maecenas egestas lorem quis tellus. Phasellus turpis pede, posuere sit amet, sagittis sollicitudin, faucibus vitae, velit. Curabitur at libero ut diam placerat feugiat. Fusce sed lacus. Maecenas metus enim, luctus non, placerat ut, ornare nec, tellus. Pellentesque ac magna eget elit suscipit auctor. Duis mattis. Ut sapien velit, ullamcorper congue, molestie et, accumsan ut, quam. Curabitur hendrerit.

Aenean pellentesque, metus a condimentum feugiat, nibh arcu tristique risus, sed bibendum magna augue at justo. Proin laoreet vestibulum sapien. Phasellus congue, libero nec fringilla consequat, ligula lorem bibendum purus, a consectetuer ligula diam et justo. Morbi id urna eget ipsum mattis dignissim. In elit. Donec gravida quam et purus. Praesent rhoncus sem quis tortor varius ornare. Fusce quis felis non leo porta sollicitudin. Donec suscipit urna. Vestibulum ornare ante nec nisl. In consectetuer libero nec sem. Aenean felis justo, pretium ut, facilisis a, consectetuer in, eros. Nulla semper semper eros. Maecenas sed nunc dignissim enim consequat rutrum.
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nam orci. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec nisl. Aenean vitae sapien. Maecenas consequat dui quis turpis. Sed convallis est ac tellus. Duis tristique. Nulla vitae neque sit amet mauris fringilla luctus. Aliquam nonummy consectetuer augue. Etiam dictum tristique diam. Fusce vel urna. Integer vitae tellus. Etiam semper dui sed nulla. Morbi pellentesque. Quisque pretium, nisi sit amet pretium dapibus, ante dolor sollicitudin tellus, a dapibus sapien orci eget lectus. Sed suscipit, ligula eget ultricies cursus, nisi libero consequat massa, vel tempus dui justo id diam. Proin suscipit sapien vel elit.

Quisque pharetra, tellus eget ornare lobortis, mauris ligula aliquet neque, sit amet laoreet leo purus eu lacus. Cras rutrum sapien ac augue. Curabitur tempor. In vestibulum, pede nec rutrum viverra, augue purus ultricies mauris, eget euismod nulla odio ornare felis. Morbi sodales mollis eros. Vivamus arcu lacus, interdum nec, sollicitudin at, tempor nec, urna. In sit amet magna. Vivamus nisi. Nulla diam leo, vehicula nec, adipiscing id, interdum non, quam. Curabitur suscipit libero non dolor. Vestibulum id lacus. Maecenas porta. Nunc semper varius pede. Duis luctus risus a nisi. Nunc non justo ultrices elit gravida mollis. Suspendisse tincidunt condimentum ante. Aenean eget sapien.

Suspendisse ut est at magna adipiscing commodo. Vestibulum fermentum commodo mauris. Vivamus pulvinar ligula quis nulla. Quisque adipiscing elit at sem auctor aliquet. Donec tellus erat, aliquam vel, gravida vel, dapibus vitae, quam. Mauris ornare. Praesent scelerisque dolor non diam. Vestibulum vel ante non metus ullamcorper dictum. In nisl neque, ultrices sodales, aliquam tempor, commodo at, massa. Aenean rutrum orci non est. Mauris hendrerit. In mollis, pede vel euismod interdum, velit metus sodales urna, sit amet elementum risus pede vel eros. In condimentum adipiscing pede. Sed odio. Curabitur adipiscing odio in dolor. Maecenas fermentum mi sed enim. Aenean ipsum. Cras semper molestie odio.

Nulla in felis. Duis malesuada libero vestibulum justo. Maecenas egestas lorem quis tellus. Phasellus turpis pede, posuere sit amet, sagittis sollicitudin, faucibus vitae, velit. Curabitur at libero ut diam placerat feugiat. Fusce sed lacus. Maecenas metus enim, luctus non, placerat ut, ornare nec, tellus. Pellentesque ac magna eget elit suscipit auctor. Duis mattis. Ut sapien velit, ullamcorper congue, molestie et, accumsan ut, quam. Curabitur hendrerit.

Aenean pellentesque, metus a condimentum feugiat, nibh arcu tristique risus, sed bibendum magna augue at justo. Proin laoreet vestibulum sapien. Phasellus congue, libero nec fringilla consequat, ligula lorem bibendum purus, a consectetuer ligula diam et justo. Morbi id urna eget ipsum mattis dignissim. In elit. Donec gravida quam et purus. Praesent rhoncus sem quis tortor varius ornare. Fusce quis felis non leo porta sollicitudin. Donec suscipit urna. Vestibulum ornare ante nec nisl. In consectetuer libero nec sem. Aenean felis justo, pretium ut, facilisis a, consectetuer in, eros. Nulla semper semper eros. Maecenas sed nunc dignissim enim consequat rutrum.
FOO;

for ($i=0; $i<1000; $i++) {
  $a = str_replace('sit', 'a', $big);
  echo $a;
  $a = str_replace('sit', 'foo', $big);
  $a = str_replace('sit', 'fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo',$big);
}

?>