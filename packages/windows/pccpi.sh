# this is the post-install for pcc on windows.  
PATH=$PATH:/usr/local/bin
SHORTDIR=`shortpath $1 $2 $3 $4 $5`

cat <<EOF>/etc/fstab
$SHORTDIR\minglicious /mingw
EOF


cat <<EOF>>/etc/profile
export PATH=\$PATH:/bigloo/2.6e/bin:/bigloo/2.6e/lib/bigloo/2.6e/:/libs
export PCC_HOME=`echo "$SHORTDIR" | sed s/\\\\\\\\/\\\\//g`
export PCC_CONF=\$PCC_HOME/etc/pcc.conf
export LD_LIBRARY_PATH=/bigloo/2.6e/lib/bigloo/2.6e:/usr/local/lib
EOF

#echo "dollar1 is $1" >> c:/installer.log
#echo "dollar2 is $2" >> c:/installer.log
#echo "dollar3 is $3" >> c:/installer.log
#echo "PATH is $PATH" >> c:/installer.log
#echo "SHORTDIR is $SHORTDIR" >> c:/installer.log

# use the longdir for the IDE
# this doubles the backslashes and strips trailing whitespace
APPDIR=`echo "$1 $2 $3 $4 $5" | sed 's/\W*$//' | sed s/\\\\\\\\/\\\\\\\\\\\\\\\\/g`
cat /pccFE.ini.tmpl | sed s/@@@app@@@/"$APPDIR"/ > /pccFE.ini
rm /pccFE.ini.tmpl

# this replaces the backslashes with forward slashes
APPDIR=`echo "$SHORTDIR" | sed s/\\\\\\\\/\\\\\\\\\\\\//g`
cat /etc/pcc.conf.tmpl | sed s/@@@app@@@/"$APPDIR"/ > /etc/pcc.conf
rm /etc/pcc.conf.tmpl

