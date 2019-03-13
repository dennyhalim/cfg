// Mozilla User Preferences
//dennyhalim.com
//http://kb.mozillazine.org/User.js_file
//http://kb.mozillazine.org/Locking_preferences
//https://developer.mozilla.org/en-US/docs/Mozilla/Preferences/A_brief_guide_to_Mozilla_preferences
pref("app.update.channel", "esr");
user_pref("browser.cache.compression_level", 1);
user_pref("browser.sessionhistory.max_entries", 10);
//user_pref("devtools.memory.enabled", false);
user_pref("browser.cache.memory.enable", false); //very usefull if you have < 4GB RAM
user_pref("network.cookie.cookieBehavior", 3);
user_pref("network.cookie.lifetimePolicy", 2);
user_pref("privacy.clearOnShutdown.cache", true);
user_pref("privacy.clearOnShutdown.offlineApps", true);
user_pref("privacy.sanitize.pending", "[{\"id\":\"shutdown\",\"itemsToClear\":[\"cache\",\"offlineApps\"],\"options\":{}}]");
//user_pref("privacy.sanitize.pending", "[{\"id\":\"shutdown\",\"itemsToClear\":[\"cache\",\"cookies\",\"offlineApps\",\"formdata\",\"sessions\",\"siteSettings\"],\"options\":{}}]");
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.pbmode.enabled", true);
user_pref("dom.webnotifications.enabled", false);
user_pref("dom.webnotifications.serviceworker.enabled", false);
user_pref("dom.serviceWorkers.enabled", false);
user_pref("browser.urlbar.placeholderName", "DuckDuckGo");
user_pref("geo.enabled", false);
user_pref("geo.provider.ms-windows-location", false);
user_pref("geo.provider.use_corelocation", false);
user_pref("geo.provider.use_gpsd", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("network.trr.mode", 2);
user_pref("network.trr.uri", "https://doh.cleanbrowsing.org/doh/adult-filter/");  //https://cleanbrowsing.org/dnsoverhttps
user_pref("dom.netinfo.enabled", false);
user_pref("media.video_stats.enabled", false);
//user_pref("dom.maxHardwareConcurrency", 1); //faster on slow devices
user_pref("dom.battery.enabled", false);
user_pref("dom.telephony.enabled", false);
user_pref("beacon.enabled", false);
user_pref("device.sensors.enabled", false);
user_pref("dom.vibrator.enabled", false);
user_pref("dom.enable_resource_timing", false);
