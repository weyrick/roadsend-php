--TEST--
posix extension test
--POST--
--GET--
--PCCARGS--
--FILE--
<?php echo posix_getcwd() ?>
--EXPECT--
--RTEXPECT--
%CWD%
