<?php
// Run: php backend/emerkit-analytics/tests/contract-test.php
$path = dirname(__DIR__) . '/includes/class-contract.php';
if (!is_file($path)) { fwrite(STDERR, "FAIL: analytics contract is not implemented\n"); exit(1); }
require $path;
use EmerKit\Analytics\Contract;
$count = 0;
function check($condition, $label) { global $count; if (!$condition) { fwrite(STDERR, "FAIL: $label\n"); exit(1); } $count++; }
function rejects($body, $label, $now) { try { Contract::events(json_encode($body), $now); } catch (InvalidArgumentException $e) { check(true, $label); return; } check(false, $label); }
$now = strtotime('2026-10-24T20:00:00Z');
$body = json_decode('{"schema":1,"installation_id":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","session_id":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","platform":"android","app_version":"0.1.19","device_language":"es-ES","ui_language":"es","attribution":{"source":"youtube","campaign":"aso_202610"},"events":[{"id":"cccccccccccccccccccccccccccccccc","name":"tool_open","tool_id":"glasgow","occurred_at":"2026-10-24T20:00:00Z"}]}');
check(count(Contract::events(json_encode($body), $now)['events']) === 1, 'valid contract accepted');
$b=clone $body;$b->attribution=null;rejects($b,'explicit attribution null rejected',$now);
foreach (['patient','gps','email','result','ip','user_agent'] as $key) { $b = clone $body; $b->$key='private'; rejects($b,"reject $key",$now); }
foreach (['unknown','deamap'] as $tool) { $b=unserialize(serialize($body)); $b->events[0]->tool_id=$tool; rejects($b,'reject invalid internal tool',$now); }
$b=unserialize(serialize($body)); $b->events[0]->name='external_tool_open'; $b->events[0]->tool_id='deamap'; check(Contract::events(json_encode($b),$now)['events'][0]['tool_id']==='deamap','external registry tool accepted');
$b=unserialize(serialize($body));$b->events[0]->occurred_at='2026-10-24T20:00:00.123456Z'; check(Contract::events(json_encode($b),$now)['events'][0]['occurred_at']==='2026-10-24T20:00:00Z','Dart UTC fraction accepted and normalized');
foreach (['2026-10-24T20:00:00.1234567Z','2026-10-17T19:59:59Z','2026-10-24T20:05:01Z','2026-02-30T20:00:00Z','2026-10-24 20:00:00','2026-10-24T20:00:00+00:00'] as $time) { $b=unserialize(serialize($body));$b->events[0]->occurred_at=$time;rejects($b,'reject event time',$now); }
foreach ([0,21] as $n) { $b=clone $body;$b->events=array_fill(0,$n,$body->events[0]); rejects($b,'batch limit',$now); }
foreach (['1.2','1.2.10000','x','1.2.3+123','01.2.3'] as $version) { $b=clone $body;$b->app_version=$version; rejects($b,'version bound',$now); }
$b=clone $body;$b->attribution=(object)['source'=>'email@example.org']; rejects($b,'PII blocked in attribution',$now);
$b=unserialize(serialize($body));$b->events[0]->startup_ms=1; rejects($b,'no metric on tool event',$now);
foreach ([-1,120001,1.5,'5',true] as $metric) { $b=unserialize(serialize($body));$b->events[0]=(object)['id'=>str_repeat('c',32),'name'=>'app_open','occurred_at'=>'2026-10-24T20:00:00Z','startup_ms'=>$metric]; rejects($b,'startup metric bound',$now); }
foreach ([0,120000] as $metric) { $b=unserialize(serialize($body));$b->events[0]=(object)['id'=>str_repeat('c',32),'name'=>'home_ready','occurred_at'=>'2026-10-24T20:00:00Z','startup_ms'=>$metric]; check(Contract::events(json_encode($b),$now)['events'][0]['startup_ms']===$metric,'startup bounds accepted'); }
foreach (['[]','null','{}',str_repeat(' ',32769)] as $raw) { try {Contract::events($raw,$now);check(false,'malformed body rejected');}catch(InvalidArgumentException $e){check(true,'malformed body rejected');} }
check(Contract::erase('{"installation_id":"'.str_repeat('a',32).'"}')===str_repeat('a',32),'erase contract');
try {Contract::erase('{"installation_id":"'.str_repeat('a',32).'","patient":"x"}');check(false,'erase unknown key');}catch(InvalidArgumentException $e){check(true,'erase unknown key');}
check(Contract::redirectAttribution(['utm_source'=>'youtube','utm_medium'=>'video'])===['source'=>'youtube','medium'=>'video'],'redirect valid attribution');
foreach ([['utm_source'=>'evil'],['utm_source'=>['youtube']],['utm_campaign'=>'a b'],['next'=>'https://evil.example'],['utm_content'=>'=1+1']] as $query) {check(Contract::redirectAttribution($query)===null,'redirect invalid stripped');}
check(Contract::redirectAttribution([])===[],'unattributed allowed');
check(strpos(Contract::destination('android',['source'=>'youtube']),'referrer=utm_source%3Dyoutube')!==false,'Android referrer encoded');
check(Contract::destination('ios',['source'=>'youtube'])==='https://apps.apple.com/app/id6760960392','Apple fixed URL no invented token');
check(!Contract::countClick('HEAD','Mozilla/5.0')&&!Contract::countClick('GET','WhatsApp/2.0')&&!Contract::countClick('GET','Googlebot'),'HEAD and bots excluded');
check(Contract::countClick('GET','Mozilla/5.0'),'browser GET counted');
check(Contract::csvCell('=HYPERLINK("x")')[0]==="'",'CSV formula escaped');
check(Contract::csvCell(' youtube')===' youtube','ordinary CSV stable');
$registry=file_get_contents(dirname(__DIR__,3).'/lib/features/home/presentation/tool_registry.dart');
preg_match_all("/id: '([^']+)'/",$registry,$matches);$expected=$matches[1];$actual=Contract::TOOLS;sort($expected);sort($actual);check($actual===$expected,'allowlist matches current ToolRegistry');
echo "PASS: $count contract checks\n";
