<?php
namespace EmerKit\Analytics;

/** Route the shared WordPress installation only on its exact dedicated hostname. */
final class HostAlias {
    const HOST = 'emerkit.globalemergency.online';
    const BASE = 'https://emerkit.globalemergency.online';
    const PUBLIC_PAGE = 'https://www.globalemergency.online/proyectos/emerkit';

    public function active() { return ($_SERVER['HTTP_HOST'] ?? '') === self::HOST; }
    public function hooks() {
        if (!$this->active()) { return; }
        // Register at plugin load, before WordPress computes login/admin redirect URLs.
        foreach (['site_url','home_url','content_url','admin_url','network_site_url','network_home_url','network_admin_url'] as $hook) { add_filter($hook, [$this, 'url'], 999); }
        add_filter('allowed_redirect_hosts', [$this, 'allowedRedirectHosts']);
        add_filter('login_redirect', [$this, 'loginRedirect'], 999);
        add_filter('wp_headers', [$this, 'headers']);
        add_action('init', [$this, 'noindex'], -100);
        add_action('template_redirect', [$this, 'frontRedirect'], -100);
    }
    public function url($url) {
        if (!$this->active() || !is_string($url)) { return $url; }
        $parts = parse_url($url);
        if (!$parts || !in_array($parts['host'] ?? '', ['globalemergency.online','www.globalemergency.online',self::HOST], true)) { return $url; }
        return self::BASE . ($parts['path'] ?? '') . (isset($parts['query']) ? '?' . $parts['query'] : '') . (isset($parts['fragment']) ? '#' . $parts['fragment'] : '');
    }
    public function allowedRedirectHosts($hosts) {
        if ($this->active() && !in_array(self::HOST, $hosts, true)) { $hosts[] = self::HOST; }
        return $hosts;
    }
    public function loginRedirect($url) {
        if (!$this->active()) { return $url; }
        $fallback = self::BASE . '/wp-admin/';
        if (!is_string($url) || preg_match('/[\x00-\x20\x7f\\\\]/', $url)) { return $fallback; }
        if (substr($url, 0, 1) === '/' && substr($url, 0, 2) !== '//') { return $url; }
        $parts = parse_url($url);
        if (!$parts || ($parts['scheme'] ?? '') !== 'https' || ($parts['host'] ?? '') !== self::HOST || isset($parts['port']) || isset($parts['user']) || isset($parts['pass'])) { return $fallback; }
        return $url;
    }
    public function headers($headers) {
        if ($this->active()) { $headers['X-Robots-Tag'] = 'noindex, nofollow'; }
        return $headers;
    }
    public function noindex() {
        if ($this->active() && !headers_sent()) { header('X-Robots-Tag: noindex, nofollow'); }
    }
    /** Keep infrastructure endpoints; all other old public content moves to Vercel. */
    public function frontTarget($uri, array $query) {
        if (!$this->active()) { return null; }
        if (isset($query['rest_route']) && is_string($query['rest_route']) && substr($query['rest_route'], 0, 1) === '/') { return null; }
        $path = parse_url($uri, PHP_URL_PATH) ?: '/';
        if (preg_match('~^/(?:wp-json(?:/|$)|wp-admin(?:/|$)|wp-login\.php$|wp-cron\.php$|wp-content(?:/|$)|wp-includes(?:/|$)|emerkit/descargar/(?:android|ios)/?$)~', $path)) { return null; }
        return self::PUBLIC_PAGE;
    }
    public function frontRedirect() {
        if (is_admin() || (defined('REST_REQUEST') && REST_REQUEST)) { return; }
        $target = $this->frontTarget($_SERVER['REQUEST_URI'] ?? '/', $_GET);
        if ($target === null) { return; }
        nocache_headers();
        wp_redirect($target, 302, 'EmerKit');
        exit;
    }
}
