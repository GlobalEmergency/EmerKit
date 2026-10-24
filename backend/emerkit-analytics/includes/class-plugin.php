<?php
namespace EmerKit\Analytics;

use InvalidArgumentException;
use RuntimeException;
use WP_REST_Response;

final class Plugin {
    const VERSION = '1';
    private $store;
    public function __construct(Store $store) { $this->store = $store; }
    public function hooks() {
        (new HostAlias())->hooks();
        add_action('rest_api_init', [$this, 'routes']);
        add_filter('rest_pre_dispatch', [$this, 'preDispatch'], 10, 3);
        add_filter('rest_pre_serve_request', [$this, 'cors'], 20, 4);
        add_action('init', [$this, 'rewrite']);
        add_filter('query_vars', function ($vars) { $vars[] = 'emerkit_store'; return $vars; });
        add_action('template_redirect', [$this, 'redirect'], 0);
        add_action('emerkit_analytics_cleanup', [$this, 'cleanup']);
        add_action('admin_menu', function () { add_management_page('EmerKit Analytics', 'EmerKit Analytics', 'manage_options', 'emerkit-analytics', [$this, 'admin']); });
        add_action('admin_post_emerkit_analytics_csv', [$this, 'export']);
        add_action('plugins_loaded', function () { if (get_option('emerkit_analytics_schema') !== self::VERSION) { $this->install(); } });
    }
    public function install() {
        global $wpdb;
        require_once ABSPATH . 'wp-admin/includes/upgrade.php';
        foreach ($this->store->schema($wpdb->get_charset_collate()) as $sql) { dbDelta($sql); }
        foreach (['events','erased','clicks'] as $suffix) {
            $table = $wpdb->prefix . 'emerkit_' . $suffix;
            if ($wpdb->get_var($wpdb->prepare('SHOW TABLES LIKE %s', $wpdb->esc_like($table))) !== $table) { throw new RuntimeException('EmerKit analytics installation failed.'); }
        }
        update_option('emerkit_analytics_schema', self::VERSION, false);
        if (!wp_next_scheduled('emerkit_analytics_cleanup')) { wp_schedule_event(time() + 300, 'daily', 'emerkit_analytics_cleanup'); }
        $this->rewrite();
        flush_rewrite_rules(false);
    }
    public function routes() {
        foreach (['events','erase'] as $route) {
            register_rest_route('emerkit/v1', '/' . $route, ['methods' => 'POST', 'callback' => [$this, $route], 'permission_callback' => '__return_true']);
        }
    }
    private function isEndpoint($request) { return in_array($request->get_route(), ['/emerkit/v1/events','/emerkit/v1/erase'], true); }
    private function response(array $data, $status = 200) {
        $response = new WP_REST_Response($data, $status);
        $response->header('Cache-Control', 'no-store, private');
        if ($status === 429) { $response->header('Retry-After', '60'); }
        return $response;
    }
    public function preDispatch($result, $server, $request) {
        if ($this->isEndpoint($request) && strlen($request->get_body()) > 32768) { return $this->response(['error' => 'body_too_large'], 413); }
        return $result;
    }
    public function cors($served, $result, $request, $server) {
        if ($this->isEndpoint($request)) {
            foreach (['Access-Control-Allow-Origin','Access-Control-Allow-Credentials','Access-Control-Allow-Methods','Access-Control-Allow-Headers','Access-Control-Expose-Headers'] as $name) { header_remove($name); }
            header('Cache-Control: no-store, private');
        }
        return $served;
    }
    /** Approximate, generous fixed-window limiter: no IP or UA is stored. */
    private function limit($identity, $limit, $seconds) {
        $window = (int) floor(time() / $seconds);
        $key = 'emerkit_rl_' . hash_hmac('sha256', $identity . ':' . $window, wp_salt('nonce'));
        $count = (int) get_transient($key);
        if ($count >= $limit) { return false; }
        // shortcut: transient increments are approximate under concurrency; use edge rate limiting if abuse appears.
        set_transient($key, $count + 1, $seconds - (time() % $seconds));
        return true;
    }
    private function allowIp() {
        // Do not trust forwarded headers: a spoofed address must not evade the limit.
        return $this->limit('ip:' . ($_SERVER['REMOTE_ADDR'] ?? 'unknown'), 1200, 600);
    }
    public function allowRate($scope, $installation, $checkIp = true) {
        return (!$checkIp || $this->allowIp()) && $this->limit($scope . ':' . $this->store->hash($installation), $scope === 'erase' ? 10 : 60, 60);
    }
    private function collect($request, $erase) {
        if (strlen($request->get_body()) > 32768) { return $this->response(['error' => 'body_too_large'], 413); }
        if (strtolower(trim(explode(';', $request->get_header('content-type'))[0])) !== 'application/json') { return $this->response(['error' => 'json_required'], 400); }
        if (!$this->allowIp()) { return $this->response(['error' => 'rate_limited'], 429); }
        try {
            $batch = $erase ? Contract::erase($request->get_body()) : Contract::events($request->get_body());
            $id = $erase ? $batch : $batch['installation_id'];
            if (!$this->allowRate($erase ? 'erase' : 'events', $id, false)) { return $this->response(['error' => 'rate_limited'], 429); }
            return $this->response($erase ? ['erased' => $this->store->erase($id)] : ['accepted' => $this->store->receive($batch)]);
        } catch (InvalidArgumentException $error) {
            return $this->response(['error' => 'invalid_payload'], 400);
        } catch (\Throwable $error) {
            // Never echo SQL, bodies, identifiers or exceptions to clients or logs.
            return $this->response(['error' => 'temporarily_unavailable'], 503);
        }
    }
    public function events($request) { return $this->collect($request, false); }
    public function erase($request) { return $this->collect($request, true); }
    public function rewrite() { add_rewrite_rule('^emerkit/descargar/(android|ios)/?$', 'index.php?emerkit_store=$matches[1]', 'top'); }
    public function redirect() {
        $platform = get_query_var('emerkit_store');
        if (!in_array($platform, ['android','ios'], true)) { return; }
        $attr = Contract::redirectAttribution(wp_unslash($_GET));
        $method = $_SERVER['REQUEST_METHOD'] ?? '';
        if ($attr !== null && Contract::countClick($method, $_SERVER['HTTP_USER_AGENT'] ?? '')) {
            try { if ($this->allowIp()) { $this->store->click($platform, $attr); } } catch (\Throwable $error) { /* Download still works during analytics outages. */ }
        }
        nocache_headers();
        header('Referrer-Policy: no-referrer');
        header('X-Robots-Tag: noindex, nofollow');
        wp_redirect(Contract::destination($platform, $attr ?? []), 302, 'EmerKit');
        exit;
    }
    public function cleanup() {
        try { $this->store->cleanup(); } catch (\Throwable $error) { /* Next scheduled cleanup retries. */ }
    }
    private function days() {
        $days = isset($_GET['days']) && is_scalar($_GET['days']) ? (int) $_GET['days'] : 28;
        return in_array($days, [7,28,90], true) ? $days : 28;
    }
    private function authorize() { if (!current_user_can('manage_options')) { wp_die('Acceso no permitido.'); } }
    private function table(array $rows) {
        if (!$rows) { echo '<p>Sin datos en este periodo.</p>'; return; }
        echo '<table class="widefat striped"><thead><tr>';
        foreach (array_keys($rows[0]) as $key) { echo '<th>' . esc_html($key) . '</th>'; }
        echo '</tr></thead><tbody>';
        foreach ($rows as $row) { echo '<tr>'; foreach ($row as $value) { echo '<td>' . esc_html((string) $value) . '</td>'; } echo '</tr>'; }
        echo '</tbody></table>';
    }
    public function admin() {
        $this->authorize();
        $days = $this->days();
        echo '<div class="wrap"><h1>EmerKit Analytics</h1><p>Participantes con consentimiento, no descargas. Clics agregados, no instalaciones atribuidas en iOS. Sin estimaciones de retención.</p>';
        echo '<form method="get"><input type="hidden" name="page" value="emerkit-analytics"><label>Periodo: <select name="days">';
        foreach ([7,28,90] as $option) { echo '<option value="' . esc_attr($option) . '"' . selected($days, $option, false) . '>' . esc_html($option) . ' días</option>'; }
        echo '</select></label> <button class="button">Filtrar</button></form>';
        $url = wp_nonce_url(add_query_arg(['action' => 'emerkit_analytics_csv','days' => $days], admin_url('admin-post.php')), 'emerkit_analytics_csv');
        echo '<p><a class="button" href="' . esc_url($url) . '">Exportar CSV agregado</a></p>';
        try {
            $report = $this->store->report($days);
            foreach (['summary' => 'Sesiones, aperturas y participantes','tools' => 'Uso de herramientas','sources' => 'Fuentes y campañas','clicks' => 'Clics hacia las stores'] as $section => $title) { echo '<h2>' . esc_html($title) . '</h2>'; $this->table($report[$section]); }
        } catch (\Throwable $error) { echo '<p>No se puede consultar la analítica en este momento.</p>'; }
        echo '<p>UTC. Eventos: ventana móvil; clics: días completos incluyendo hoy. Datos conservados 180 días. unknown indica atribución desconocida. Una sesión cuenta si tiene algún evento; aperturas = app_open. Los eventos pueden llegar hasta 7 días después.</p></div>';
    }
    public function export() {
        $this->authorize();
        check_admin_referer('emerkit_analytics_csv');
        try { $report = $this->store->report($this->days()); } catch (\Throwable $error) { wp_die('No se puede exportar la analítica en este momento.'); return; }
        nocache_headers();
        header('Content-Type: text/csv; charset=utf-8');
        header('Content-Disposition: attachment; filename="01-emerkit-analytics.csv"');
        $output = fopen('php://output', 'w');
        foreach ($report as $section => $rows) {
            fputcsv($output, [$section], ',', '"', '');
            if ($rows) {
                fputcsv($output, array_keys($rows[0]), ',', '"', '');
                foreach ($rows as $row) { fputcsv($output, array_map([Contract::class, 'csvCell'], array_values($row)), ',', '"', ''); }
            }
            fputcsv($output, [], ',', '"', '');
        }
        fclose($output);
        exit;
    }
}
