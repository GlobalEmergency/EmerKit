<?php
$path=dirname(__DIR__).'/includes/class-host-alias.php';
if(!is_file($path)){fwrite(STDERR,"FAIL: dedicated host alias is not implemented\n");exit(1);}
require $path;
use EmerKit\Analytics\HostAlias;
function add_filter(...$args){$GLOBALS['hooks'][]=$args;}
function add_action(...$args){$GLOBALS['hooks'][]=$args;}
$count=0;
function hostCheck($condition,$label){global $count;if(!$condition){fwrite(STDERR,"FAIL: $label\n");exit(1);} $count++;}
$alias=new HostAlias();
foreach(['www.globalemergency.online','globalemergency.online','emerkit.globalemergency.online.evil.example','emerkit.globalemergency.online:443','evil.example','']as$host){
 $_SERVER['HTTP_HOST']=$host;$GLOBALS['hooks']=[];$alias->hooks();
 hostCheck(!$alias->active()&&$GLOBALS['hooks']===[],'other and attacker hosts do not change hooks');
 hostCheck($alias->url('https://www.globalemergency.online/wp-login.php')==='https://www.globalemergency.online/wp-login.php','other hosts do not change URLs');
 hostCheck($alias->headers(['Existing'=>'value'])===['Existing'=>'value'],'other hosts retain headers');
 hostCheck($alias->allowedRedirectHosts(['existing.example'])===['existing.example'],'other hosts retain allowed redirects');
}
$_SERVER['HTTP_HOST']='emerkit.globalemergency.online';$GLOBALS['hooks']=[];$alias->hooks();
hostCheck($alias->active(),'exact dedicated host active');
$names=array_column($GLOBALS['hooks'],0);foreach(['site_url','home_url','content_url','admin_url','allowed_redirect_hosts','login_redirect','wp_headers','init','template_redirect']as$name){hostCheck(in_array($name,$names,true),'required alias hook '.$name);}
foreach(['https://www.globalemergency.online','http://globalemergency.online','//www.globalemergency.online']as$origin){hostCheck($alias->url($origin.'/wp-admin/tools.php?page=emerkit-analytics#x')==='https://emerkit.globalemergency.online/wp-admin/tools.php?page=emerkit-analytics#x','known WP origins mapped preserving path/query');}
foreach(['https://evil.example/wp-login.php','https://globalemergency.online.evil.example/wp-admin/','/wp-admin/','javascript:alert(1)']as$url){hostCheck($alias->url($url)===$url,'unrelated URLs are not rewritten');}
hostCheck($alias->headers([])['X-Robots-Tag']==='noindex, nofollow','alias responses noindex');
hostCheck(in_array('emerkit.globalemergency.online',$alias->allowedRedirectHosts([]),true),'safe redirects allow constant alias');
foreach(['https://evil.example/','//evil.example/','https://emerkit.globalemergency.online.evil.example/','https://user@emerkit.globalemergency.online/wp-admin/','http://emerkit.globalemergency.online/wp-admin/','https://emerkit.globalemergency.online:444/wp-admin/','/\\evil.example/']as$url){hostCheck($alias->loginRedirect($url)==='https://emerkit.globalemergency.online/wp-admin/','unsafe login targets return private admin');}
hostCheck($alias->loginRedirect('https://emerkit.globalemergency.online/wp-admin/tools.php?page=emerkit-analytics')==='https://emerkit.globalemergency.online/wp-admin/tools.php?page=emerkit-analytics','login returns to same-host panel');
hostCheck($alias->loginRedirect('/wp-admin/')==='/wp-admin/','safe relative login return allowed');
foreach(['/','/old-page/','/emerkit/','/wp-json-evil/']as$path){hostCheck($alias->frontTarget($path,[])==='https://www.globalemergency.online/proyectos/emerkit','old front page redirected');}
foreach(['/wp-json/emerkit/v1/events','/wp-admin/','/wp-login.php','/wp-content/a.css','/wp-includes/a.js','/wp-cron.php','/emerkit/descargar/android/','/emerkit/descargar/ios/']as$path){hostCheck($alias->frontTarget($path,[])===null,'operational path preserved '.$path);}
hostCheck($alias->frontTarget('/',['rest_route'=>'/emerkit/v1/events'])===null,'plain REST permalinks preserved');
$_SERVER['HTTP_HOST']='www.globalemergency.online';hostCheck($alias->frontTarget('/old-page/',[])===null,'primary host front unchanged');
echo "PASS: $count dedicated-host guards and URL/redirect checks\n";
