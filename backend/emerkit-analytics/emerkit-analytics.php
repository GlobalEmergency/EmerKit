<?php
/**
 * Plugin Name: EmerKit Analytics
 * Description: Analítica consentida de EmerKit, enlaces a stores y estadísticas privadas.
 * Version: 1.0.1
 * Requires at least: 6.4
 * Requires PHP: 7.4
 * License: MIT
 */
if (!defined('ABSPATH')) { exit; }
require_once __DIR__ . '/includes/class-contract.php';
require_once __DIR__ . '/includes/class-store.php';
require_once __DIR__ . '/includes/class-host-alias.php';
require_once __DIR__ . '/includes/class-plugin.php';
$emerkit_analytics = new \EmerKit\Analytics\Plugin(new \EmerKit\Analytics\Store($GLOBALS['wpdb']));
$emerkit_analytics->hooks();
register_activation_hook(__FILE__, [$emerkit_analytics, 'install']);
register_deactivation_hook(__FILE__, function () { wp_clear_scheduled_hook('emerkit_analytics_cleanup'); flush_rewrite_rules(false); });
