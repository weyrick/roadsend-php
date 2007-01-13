<?


echo version_compare("4.0.4", "4.0.6");

echo version_compare("4.3.2RC1", "4.0.6RC2");

echo version_compare("4.0.6alpha", "4.0.6beta");

echo version_compare("4.0.6-alpha", "4.0.6+beta");
echo version_compare("4.1.0_test", "4.0.6.9_test2");

echo version_compare("4.0.4", "4.0.6", "<");
echo version_compare("4.0.6", "4.0.6", "eq");

echo version_compare("5.2.1.4","5.2.1.4.3");

?>