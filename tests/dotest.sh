#! /bin/bash

if [  -z $PHPHOME ]; then 
    export PHPHOME=`pwd`
fi


PHP=php
#$HOME/php-4.2.3/php 
PHPFLAGS=-f
PHPOO=$PHPHOME/phpoo
PHPOOFLAGS=
TESTHOME=$PHPHOME/tests
TIME=/usr/bin/time

TARGET=$1
TESTDIR=$2

if [ -z $TESTDIR ]; then
    TESTDIR=test_`date +"%b_%d_%k:00"`
fi


TOTAL=0
BUILDFAIL=0
RUNFAIL=0

fail () {
   echo -e "\033[31;1m [FAIL] \033[0m"
}

pass () {
   echo -ne "\033[32;1m [PASS] \033[0m"
}

slow () {
   echo -ne "\033[33;1m [SLOW] \033[0m"
}

dotest () {
    TOTAL=$(($TOTAL + 1))
    echo -ne "$1:\n\t"
    cp $TESTHOME/$1 ./
    $TIME -f "%e" -o $1.empire.time $PHP $PHPFLAGS $1 &> $1.evilempire

    BINARY=`echo $1 |sed s/.php\$//`
    echo -n "build: "
    if $PHPOO $PHPOOFLAGS $1 > $BINARY.log 2>&1; then
	pass
    else
	BUILDFAIL=$(($BUILDFAIL + 1))
	fail
	if [ $SINGLEMODE = "true" ]; then
	    cat $BINARY.log
	fi
	return
    fi
    echo -n " run: "
    $TIME -f "%e" -o $1.rebels.time ./$BINARY &> $1.rebels
    if diff $1.evilempire $1.rebels > $1.diff; then
	pass
    else
	RUNFAIL=$(($RUNFAIL + 1))
	fail
	if [ $SINGLEMODE = "true" ]; then
	    cat $1.diff
	fi
	return
    fi

    REBELTIME=`cat $1.rebels.time`
    EMPIRETIME=`cat $1.empire.time`
    echo -n " speed: $EMPIRETIME / $REBELTIME"

    echo
}


#rm -rf $TESTDIR

if [ ! -d $TESTDIR ]; then 
    mkdir $TESTDIR
fi

#hack for include files
cp $TESTHOME/*.inc $TESTDIR/


cd $TESTDIR

if [ $TARGET = "all" ]; then
    SINGLEMODE=false
    for i in `find $TESTHOME -name "*.php" -printf "%f\n" -maxdepth 1`; do
        dotest $i;
    done
else
    echo "running test $TARGET"    
    SINGLEMODE=true
    dotest $TARGET;
fi

echo "Of $TOTAL total tests, $BUILDFAIL failed to compile, and $RUNFAIL ran wrong."

