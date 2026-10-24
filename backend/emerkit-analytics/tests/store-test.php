<?php
// Store integration harness requires an ephemeral MySQL/MariaDB (no WordPress).
$path = dirname(__DIR__) . '/includes/class-store.php';
if (!is_file($path)) {fwrite(STDERR,"FAIL: store not implemented\n");exit(1);}
require $path;
define('ARRAY_A', 'ARRAY_A');
class TestWpdb {
    public $prefix='test_'; public $last_error=''; private $pdo;
    function __construct(){ $this->pdo=new PDO('mysql:host='.getenv('DB_HOST').';dbname=analytics','root','',[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]); }
    function prepare($sql,...$args){$i=0;return preg_replace_callback('/%[sdf]/',function($m)use(&$i,$args){$value=$args[$i++];return $m[0]==='%s'?$this->pdo->quote($value):(string)(int)$value;},$sql);}
    function query($sql){try{$this->last_error='';return $this->pdo->exec($sql);}catch(Throwable $e){$this->last_error=$e->getMessage();return false;}}
    function get_results($sql,$format){try{$this->last_error='';return $this->pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC);}catch(Throwable $e){$this->last_error=$e->getMessage();return [];}}
    function get_var($sql){try{$this->last_error='';return $this->pdo->query($sql)->fetchColumn();}catch(Throwable $e){$this->last_error=$e->getMessage();return null;}}
}
function wp_salt($scheme){return 'isolated-test-only-salt';}
function checkStore($value,$label){if(!$value){fwrite(STDERR,"FAIL: $label\n");exit(1);}}
$db=new TestWpdb();$store=new EmerKit\Analytics\Store($db);
foreach(['events','erased','clicks']as$table){$db->query('DROP TABLE IF EXISTS test_emerkit_'.$table);}
foreach($store->schema('')as$sql){checkStore($db->query($sql)!==false,'create tables');}
$payload=['installation_id'=>str_repeat('a',32),'session_id'=>str_repeat('b',32),'platform'=>'android','app_version'=>'0.1.19','device_language'=>'es-ES','ui_language'=>'es','attribution'=>['source'=>'youtube'],'events'=>[['id'=>str_repeat('c',32),'name'=>'tool_open','tool_id'=>'glasgow','occurred_at'=>gmdate('Y-m-d\TH:i:s\Z')]]];
checkStore($store->receive($payload)===1,'one new event accepted');
checkStore($store->receive($payload)===0,'retry deduplicated');
$badBatch=$payload;$badBatch['events']=[['id'=>str_repeat('d',32),'name'=>'app_open','occurred_at'=>gmdate('Y-m-d\TH:i:s\Z')],['id'=>str_repeat('e',32),'name'=>'tool_open','tool_id'=>str_repeat('x',100),'occurred_at'=>gmdate('Y-m-d\TH:i:s\Z')]];
try{$store->receive($badBatch);checkStore(false,'failed insert must roll back');}catch(RuntimeException $error){checkStore(true,'storage failure surfaced');}
checkStore((int)$db->get_var('SELECT COUNT(*) FROM test_emerkit_events')===1,'batch rollback preserves atomicity');
$report=$store->report(7);
checkStore((int)$report['summary'][0]['sessions']===1 && (int)$report['summary'][0]['participants']===1,'report counts actual sessions and participants');
checkStore($report['tools'][0]['tool_id']==='glasgow' && $report['sources'][0]['source']==='youtube','report tool/source aggregates');
checkStore((int)$db->get_var('SELECT COUNT(*) FROM test_emerkit_events')===1,'only one event stored');
checkStore($db->get_var('SELECT installation_hash FROM test_emerkit_events')!==$payload['installation_id'],'raw installation not stored');
$other=new TestWpdb();$lock=$store->lockName($payload['installation_id']);
checkStore((int)$other->get_var($other->prepare('SELECT GET_LOCK(%s,0)',$lock))===1,'competing request locks installation');
try{$store->erase($payload['installation_id']);checkStore(false,'busy lock must fail');}catch(RuntimeException $e){checkStore(true,'busy erase can retry');}
$other->get_var($other->prepare('SELECT RELEASE_LOCK(%s)',$lock));
checkStore($store->erase($payload['installation_id'])===1,'erase deletes event');
checkStore($store->receive($payload)===0,'in-flight event blocked after erase');
checkStore((int)$db->get_var('SELECT COUNT(*) FROM test_emerkit_events')===0,'erased history does not return');
checkStore((int)$db->get_var('SELECT COUNT(*) FROM test_emerkit_erased')===1,'tombstone retained');
$store->click('android',['source'=>'youtube']);$store->click('android',['source'=>'youtube']);
checkStore((int)$db->get_var('SELECT SUM(clicks) FROM test_emerkit_clicks')===2,'click counter aggregated');
checkStore((int)$db->get_var('SELECT COUNT(*) FROM test_emerkit_clicks')===1,'clicks have no individual records');
$db->query("UPDATE test_emerkit_erased SET expires_at='2000-01-01 00:00:00'");
$db->query("UPDATE test_emerkit_clicks SET day='2000-01-01'");
$store->cleanup();
checkStore((int)$db->get_var('SELECT COUNT(*) FROM test_emerkit_erased')===0,'expired tombstones removed');
checkStore((int)$db->get_var('SELECT COUNT(*) FROM test_emerkit_clicks')===0,'expired aggregates removed');
$store->receive($payload);$db->query("UPDATE test_emerkit_events SET occurred_at='2000-01-01 00:00:00'");$store->cleanup();
checkStore((int)$db->get_var('SELECT COUNT(*) FROM test_emerkit_events')===0,'events expire at 180 days');
echo "PASS: persistence, deduplication, HMAC, locking, erasure, aggregation, retention\n";
