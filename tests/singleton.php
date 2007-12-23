<?

class Example
{
    // Hold an instance of the class
    private static $instance;
    
    // A private constructor; prevents direct creation of object
    private function __construct() 
    {
        echo 'I am constructed';
    }

    // The singleton method
    public static function singleton() 
    {
        if (!isset(self::$instance)) {
            $c = __CLASS__;
            self::$instance = new $c;
        }

        return self::$instance;
    }
    
    // Example method
    public function bark()
    {
        echo 'Woof!';
    }

    // Prevent users to clone the instance
    public function __clone()
    {
        //trigger_error('Clone is not allowed.', E_USER_ERROR);
        echo "throw clone error\n";
    }


}

// This would fail because the constructor is private
//$test = new Example;

// This will always retrieve a single instance of the class
$test = Example::singleton();
$test->bark();

// This will issue an E_USER_ERROR.
$test_clone = clone $test;

?>

