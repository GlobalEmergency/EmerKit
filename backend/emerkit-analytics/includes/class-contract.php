<?php
namespace EmerKit\Analytics;

use DateTimeImmutable;
use DateTimeZone;
use InvalidArgumentException;
use stdClass;

/** Pure HTTP contract. No clinical fields or unbounded dimensions are accepted. */
final class Contract {
    const TOOLS = ['rcp_rithm','plan_rcp','deamap','glasgow','triage','tep','cincinnati','madrid_direct','nihss','rankin','vital_signs','heart_rate','respiratory_rate','glucemia','hipotermia','hipertermia','shock_index','o2_calculator','oxigenoterapia','ecg','wallace','lund_browder','vendajes','heridas','posiciones','diluciones','apgar','epi','adr','comm','glosario','gps_converter'];
    const SOURCES = ['web','youtube','whatsapp','instagram','qr','email'];
    const ATTRIBUTION = ['source','medium','campaign','content'];

    private static function fail() { throw new InvalidArgumentException('Invalid analytics payload.'); }
    private static function objectKeys($value, array $allowed, array $required = []) {
        if (!$value instanceof stdClass || array_diff(array_keys(get_object_vars($value)), $allowed) || array_diff($required, array_keys(get_object_vars($value)))) { self::fail(); }
    }
    private static function matches($value, $pattern) { return is_string($value) && preg_match($pattern, $value) === 1; }
    private static function decode($raw) {
        if (!is_string($raw) || strlen($raw) > 32768) { self::fail(); }
        $value = json_decode($raw, false, 12);
        if (json_last_error() !== JSON_ERROR_NONE || !$value instanceof stdClass) { self::fail(); }
        return $value;
    }
    public static function installationId($value) {
        if (!self::matches($value, '/\A[a-f0-9]{32}\z/D')) { self::fail(); }
        return $value;
    }
    public static function erase($raw) {
        $value = self::decode($raw);
        self::objectKeys($value, ['installation_id'], ['installation_id']);
        return self::installationId($value->installation_id);
    }
    public static function events($raw, $now = null) {
        $now = $now ?? time();
        $value = self::decode($raw);
        $required = ['schema','installation_id','session_id','platform','app_version','device_language','ui_language','events'];
        self::objectKeys($value, array_merge($required, ['attribution']), $required);
        if ($value->schema !== 1) { self::fail(); }
        self::installationId($value->installation_id);
        self::installationId($value->session_id);
        if (!in_array($value->platform, ['android','ios','web'], true) || !in_array($value->ui_language, ['es','en'], true)) { self::fail(); }
        if (!self::matches($value->app_version, '/\A(?:0|[1-9][0-9]{0,3})\.(?:0|[1-9][0-9]{0,3})\.(?:0|[1-9][0-9]{0,3})\z/D') || !self::matches($value->device_language, '/\A[a-zA-Z]{2,8}(?:-[a-zA-Z0-9]{1,8})*\z/D') || strlen($value->device_language) > 35) { self::fail(); }
        $attribution = property_exists($value, 'attribution') ? $value->attribution : new stdClass();
        self::objectKeys($attribution, self::ATTRIBUTION);
        foreach (get_object_vars($attribution) as $part) { if (!self::matches($part, '/\A[a-z0-9_-]{1,48}\z/D')) { self::fail(); } }
        if (!is_array($value->events) || count($value->events) < 1 || count($value->events) > 20) { self::fail(); }
        $events = [];
        foreach ($value->events as $event) {
            self::objectKeys($event, ['id','name','tool_id','occurred_at','startup_ms'], ['id','name','occurred_at']);
            self::installationId($event->id);
            if (!in_array($event->name, ['measurement_started','app_open','home_ready','tool_open','external_tool_open'], true)) { self::fail(); }
            $isTool = in_array($event->name, ['tool_open','external_tool_open'], true);
            if ($isTool) {
                if (!isset($event->tool_id) || !in_array($event->tool_id, self::TOOLS, true) || (($event->name === 'external_tool_open') !== ($event->tool_id === 'deamap'))) { self::fail(); }
            } elseif (property_exists($event, 'tool_id')) { self::fail(); }
            if (property_exists($event, 'startup_ms') && (!in_array($event->name, ['app_open','home_ready'], true) || !is_int($event->startup_ms) || $event->startup_ms < 0 || $event->startup_ms > 120000)) { self::fail(); }
            if (!self::matches($event->occurred_at, '/\A[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:\.[0-9]{1,6})?Z\z/D')) { self::fail(); }
            $parts = explode('.', substr($event->occurred_at, 0, -1));
            $canonical = $parts[0] . '.' . str_pad($parts[1] ?? '', 6, '0') . 'Z';
            $date = DateTimeImmutable::createFromFormat('!Y-m-d\TH:i:s.u\Z', $canonical, new DateTimeZone('UTC'));
            if (!$date || $date->format('Y-m-d\TH:i:s.u\Z') !== $canonical || (float) $date->format('U.u') < $now - 604800 || (float) $date->format('U.u') > $now + 300) { self::fail(); }
            $event->occurred_at = $date->format('Y-m-d\TH:i:s\Z');
            $events[] = get_object_vars($event);
        }
        $result = get_object_vars($value);
        $result['attribution'] = get_object_vars($attribution);
        $result['events'] = $events;
        return $result;
    }
    /** null means invalid: send to the fixed store without attribution or counting. */
    public static function redirectAttribution(array $query) {
        $result = [];
        foreach ($query as $key => $value) {
            if (!in_array($key, array_map(function ($part) { return 'utm_' . $part; }, self::ATTRIBUTION), true) || !self::matches($value, '/\A[a-z0-9_-]{1,48}\z/D')) { return null; }
            $result[substr($key, 4)] = $value;
        }
        if (isset($result['source']) && !in_array($result['source'], self::SOURCES, true)) { return null; }
        return $result;
    }
    public static function destination($platform, array $attribution) {
        if ($platform === 'ios') { return 'https://apps.apple.com/app/id6760960392'; }
        $url = 'https://play.google.com/store/apps/details?id=online.globalemergency.emerkit';
        $utm = [];
        foreach (self::ATTRIBUTION as $part) { if (isset($attribution[$part])) { $utm['utm_' . $part] = $attribution[$part]; } }
        return $utm ? $url . '&referrer=' . rawurlencode(http_build_query($utm, '', '&', PHP_QUERY_RFC3986)) : $url;
    }
    public static function countClick($method, $agent) {
        return $method === 'GET' && !preg_match('/bot|crawl|spider|preview|facebookexternalhit|whatsapp|slurp|headless|wget|curl|python|fetch|monitor|scanner/i', $agent);
    }
    public static function csvCell($value) {
        $value = (string) $value;
        return preg_match('/\A[\s]*[=+@-]/', $value) ? "'" . $value : $value;
    }
}
