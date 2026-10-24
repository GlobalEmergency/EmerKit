<?php
$base=dirname(__DIR__);
if(!is_file($base.'/includes/class-plugin.php')){fwrite(STDERR,"FAIL: WP adapter not implemented\n");exit(1);}
require $base.'/includes/class-contract.php';require $base.'/includes/class-store.php';require $base.'/includes/class-plugin.php';
class WP_REST_Response {public $data;public $status;function __construct($data,$status=200){$this->data=$data;$this->status=$status;}function header($k,$v){}}
class Request {private $body;function __construct($body){$this->body=$body;}function get_body(){return $this->body;}function get_header($name){return 'application/json';}function get_route(){return '/emerkit/v1/events';}}
function get_transient($key){return $GLOBALS['transients'][$key]??false;}
function set_transient($key,$value,$ttl){$GLOBALS['transients'][$key]=$value;return true;}
function wp_salt($scheme){return 'test-salt';}
function current_user_can($cap){return $GLOBALS['is_admin']??false;}
function check_admin_referer($action){throw new RuntimeException('nonce');}
function wp_die($message){throw new RuntimeException('forbidden');}
function checkWp($value,$label){if(!$value){fwrite(STDERR,"FAIL: $label\n");exit(1);}}
class NoDatabase {public $prefix='test_';}
$plugin=new EmerKit\Analytics\Plugin(new EmerKit\Analytics\Store(new NoDatabase()));
$_SERVER['REMOTE_ADDR']='192.0.2.1';
$response=$plugin->events(new Request('{"patient":"private"}'));
checkWp($response->status===400,'invalid event rejected before database access');
$response=$plugin->erase(new Request('{"installation_id":"x"}'));
checkWp($response->status===400,'invalid erase rejected before database access');
$response=$plugin->preDispatch(null,null,new Request(str_repeat(' ',32769)));
checkWp($response->status===413,'body cap enforced before REST JSON decode');
for($i=0;$i<60;$i++){checkWp($plugin->allowRate('events',str_repeat('a',32)),'installation limit allows normal traffic');}
checkWp(!$plugin->allowRate('events',str_repeat('a',32)),'installation limit blocks excess');
checkWp($plugin->allowRate('erase',str_repeat('a',32)),'erasure has independent quota');
checkWp($plugin->allowRate('events',str_repeat('b',32)),'shared NAT does not block another installation');
try{$plugin->admin();checkWp(false,'admin must be private');}catch(RuntimeException $e){checkWp($e->getMessage()==='forbidden','admin capability checked');}
try{$plugin->export();checkWp(false,'export must be private');}catch(RuntimeException $e){checkWp($e->getMessage()==='forbidden','export capability checked');}
$GLOBALS['is_admin']=true;
try{$plugin->export();checkWp(false,'export requires nonce');}catch(RuntimeException $e){checkWp($e->getMessage()==='nonce','export nonce checked before report');}
echo "PASS: REST guards, size cap, installation limits, NAT, erase quota, admin/export access\n";
