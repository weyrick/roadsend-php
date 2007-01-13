<?

$data = "
<MeMudd> doh
<MeMudd> well get on it
<Gollum> :)
<Gollum> did you see the bot sign off
<MeMudd> slacker
<Gollum> it should be back in a min
<MeMudd> did you see it sign back on?
<MeMudd> yeah whats up
<Gollum> ;
<Gollum> ;)
<Gollum> it's the irc server 
<Gollum> it's slow
--> Smeagol (~PircBot@u1037566.net) has joined #mudsville
--- Gollum gives channel operator status to Smeagol
<Smeagol> Thanks
<MeMudd> sure sure, blame it on the irc server. Mr Developer, developers always blame it on Admins
<Gollum> I'm ont a developer
<MeMudd> then what is you?
<Gollum> I only play one on T.V.
<Gollum> I'm not really a computer geek at all.
<Gollum> I work at McDonalds.
<Gollum> would you like fries with that B.S. burger?
<MeMudd> sure
<no_l0gic> mmm... fries <drool>
<no_l0gic> and buttered bacon?
<Gollum> bacon cheese burger with onion rings ;)
<Gollum> and a beer
";

echo chunk_split($data,10);

echo chunk_split($data,5);

echo chunk_split($data);

echo chunk_split($data, 10, "-blah-\n");

?>