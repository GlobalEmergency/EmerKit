<?php
namespace EmerKit\Analytics;

use RuntimeException;

/** Persistence only; callers must validate the complete batch with Contract first. */
final class Store {
    private $db;
    private $events;
    private $erased;
    private $clicks;
    public function __construct($db) {
        $this->db = $db;
        $this->events = $db->prefix . 'emerkit_events';
        $this->erased = $db->prefix . 'emerkit_erased';
        $this->clicks = $db->prefix . 'emerkit_clicks';
    }
    public function schema($collate) {
        return ["CREATE TABLE {$this->events} (
            event_id char(32) NOT NULL,
            installation_hash char(64) NOT NULL,
            session_hash char(64) NOT NULL,
            event_name varchar(32) NOT NULL,
            tool_id varchar(48) NOT NULL DEFAULT '',
            platform varchar(8) NOT NULL,
            app_version varchar(20) NOT NULL,
            device_language varchar(35) NOT NULL,
            ui_language varchar(2) NOT NULL,
            source varchar(48) NOT NULL DEFAULT '',
            medium varchar(48) NOT NULL DEFAULT '',
            campaign varchar(48) NOT NULL DEFAULT '',
            content varchar(48) NOT NULL DEFAULT '',
            startup_ms int unsigned DEFAULT NULL,
            occurred_at datetime NOT NULL,
            received_at datetime NOT NULL,
            PRIMARY KEY  (event_id),
            KEY installation_time (installation_hash,occurred_at),
            KEY occurred_at (occurred_at),
            KEY event_time (event_name,occurred_at)
        ) ENGINE=InnoDB $collate;", "CREATE TABLE {$this->erased} (
            installation_hash char(64) NOT NULL,
            expires_at datetime NOT NULL,
            PRIMARY KEY  (installation_hash),
            KEY expires_at (expires_at)
        ) ENGINE=InnoDB $collate;", "CREATE TABLE {$this->clicks} (
            day date NOT NULL,
            platform varchar(8) NOT NULL,
            attribution_hash char(64) NOT NULL,
            source varchar(48) NOT NULL DEFAULT '',
            medium varchar(48) NOT NULL DEFAULT '',
            campaign varchar(48) NOT NULL DEFAULT '',
            content varchar(48) NOT NULL DEFAULT '',
            clicks bigint unsigned NOT NULL DEFAULT 0,
            PRIMARY KEY  (day,platform,attribution_hash)
        ) ENGINE=InnoDB $collate;"];
    }
    public function hash($installation) { return hash_hmac('sha256', $installation, wp_salt('auth')); }
    public function lockName($installation) { return 'emerkit_' . substr($this->hash($installation), 0, 56); }
    private function query($sql) {
        $result = $this->db->query($sql);
        if ($result === false) { throw new RuntimeException('Analytics storage unavailable.'); }
        return $result;
    }
    private function locked($installation, callable $work) {
        $name = $this->lockName($installation);
        if ((int) $this->db->get_var($this->db->prepare('SELECT GET_LOCK(%s,2)', $name)) !== 1) { throw new RuntimeException('Analytics installation busy.'); }
        try {
            $this->query('START TRANSACTION');
            $result = $work($this->hash($installation));
            $this->query('COMMIT');
            return $result;
        } catch (\Throwable $error) {
            $this->db->query('ROLLBACK');
            throw $error;
        } finally {
            $this->db->get_var($this->db->prepare('SELECT RELEASE_LOCK(%s)', $name));
        }
    }
    public function receive(array $batch) {
        return $this->locked($batch['installation_id'], function ($hash) use ($batch) {
            $blocked = $this->db->get_var($this->db->prepare("SELECT installation_hash FROM {$this->erased} WHERE installation_hash=%s AND expires_at>UTC_TIMESTAMP()", $hash));
            if ($this->db->last_error) { throw new RuntimeException('Analytics storage unavailable.'); }
            if ($blocked) { return 0; }
            $accepted = 0;
            $session = hash_hmac('sha256', $batch['installation_id'] . ':' . $batch['session_id'], wp_salt('auth'));
            $attr = $batch['attribution'];
            foreach ($batch['events'] as $event) {
                // ON DUPLICATE is a no-op: retries cannot alter an already accepted event.
                $sql = "INSERT INTO {$this->events} (event_id,installation_hash,session_hash,event_name,tool_id,platform,app_version,device_language,ui_language,source,medium,campaign,content,startup_ms,occurred_at,received_at) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s," . (isset($event['startup_ms']) ? '%d' : 'NULL') . ",%s,%s) ON DUPLICATE KEY UPDATE event_id=event_id";
                $args = [$event['id'],$hash,$session,$event['name'],$event['tool_id'] ?? '',$batch['platform'],$batch['app_version'],$batch['device_language'],$batch['ui_language'],$attr['source'] ?? '',$attr['medium'] ?? '',$attr['campaign'] ?? '',$attr['content'] ?? ''];
                if (isset($event['startup_ms'])) { $args[] = $event['startup_ms']; }
                $args[] = str_replace(['T','Z'], [' ',''], $event['occurred_at']);
                $args[] = gmdate('Y-m-d H:i:s');
                $accepted += $this->query($this->db->prepare($sql, ...$args)) === 1 ? 1 : 0;
            }
            return $accepted;
        });
    }
    public function erase($installation) {
        return $this->locked($installation, function ($hash) {
            $this->query($this->db->prepare("INSERT INTO {$this->erased} (installation_hash,expires_at) VALUES (%s,DATE_ADD(UTC_TIMESTAMP(),INTERVAL 7 DAY)) ON DUPLICATE KEY UPDATE expires_at=VALUES(expires_at)", $hash));
            return $this->query($this->db->prepare("DELETE FROM {$this->events} WHERE installation_hash=%s", $hash));
        });
    }
    public function click($platform, array $attr) {
        $parts = [$attr['source'] ?? '',$attr['medium'] ?? '',$attr['campaign'] ?? '',$attr['content'] ?? ''];
        $this->query($this->db->prepare("INSERT INTO {$this->clicks} (day,platform,attribution_hash,source,medium,campaign,content,clicks) VALUES (%s,%s,%s,%s,%s,%s,%s,1) ON DUPLICATE KEY UPDATE clicks=clicks+1", gmdate('Y-m-d'), $platform, hash('sha256', json_encode($parts)), ...$parts));
    }
    public function cleanup() {
        $this->query("DELETE FROM {$this->events} WHERE occurred_at<DATE_SUB(UTC_TIMESTAMP(),INTERVAL 180 DAY)");
        $this->query("DELETE FROM {$this->clicks} WHERE day<DATE_SUB(UTC_DATE(),INTERVAL 180 DAY)");
        $this->query("DELETE FROM {$this->erased} WHERE expires_at<=UTC_TIMESTAMP()");
    }
    /** Aggregates only: never exposes installation, event or session identifiers. */
    public function report($days) {
        $days = in_array($days, [7,28,90], true) ? $days : 28;
        $where = $this->db->prepare('occurred_at>=DATE_SUB(UTC_TIMESTAMP(),INTERVAL %d DAY)', $days);
        $queries = [
            'summary' => "SELECT COUNT(DISTINCT session_hash) AS sessions,COUNT(DISTINCT installation_hash) AS participants,COALESCE(SUM(event_name='app_open'),0) AS app_opens,COALESCE(SUM(event_name='home_ready'),0) AS home_ready FROM {$this->events} WHERE $where",
            'tools' => "SELECT tool_id,event_name,COUNT(*) AS events,COUNT(DISTINCT installation_hash) AS participants FROM {$this->events} WHERE $where AND event_name IN ('tool_open','external_tool_open') GROUP BY tool_id,event_name ORDER BY events DESC",
            'sources' => "SELECT COALESCE(NULLIF(source,''),'unknown') AS source,medium,campaign,content,COUNT(*) AS events,COUNT(DISTINCT installation_hash) AS participants FROM {$this->events} WHERE $where GROUP BY source,medium,campaign,content ORDER BY events DESC",
            'clicks' => $this->db->prepare("SELECT platform,COALESCE(NULLIF(source,''),'unknown') AS source,medium,campaign,content,SUM(clicks) AS clicks FROM {$this->clicks} WHERE day>=DATE_SUB(UTC_DATE(),INTERVAL %d DAY) GROUP BY platform,source,medium,campaign,content ORDER BY clicks DESC", $days - 1),
        ];
        $result = [];
        foreach ($queries as $name => $sql) {
            $result[$name] = $this->db->get_results($sql, ARRAY_A);
            if ($this->db->last_error) { throw new RuntimeException('Analytics report unavailable.'); }
        }
        return $result;
    }
}
