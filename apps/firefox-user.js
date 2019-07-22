// Mozilla User Preferences
//dennyhalim.com
//http://kb.mozillazine.org/User.js_file
//http://kb.mozillazine.org/Locking_preferences
//https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig
//https://developer.mozilla.org/en-US/docs/Mozilla/Preferences/A_brief_guide_to_Mozilla_preferences
//https://ffprofile.com/
//https://github.com/pyllyukko/user.js#installation
//lockPref("autoadmin.global_config_url","https://github.com/dennyhalim/cfg/raw/master/apps/firefox-user.js");
pref("app.update.channel", "esr");
user_pref("beacon.enabled", false);
user_pref("browser.cache.disk.enable", false); //very usefull if you have < 4GB RAM
user_pref("browser.cache.compression_level", 1);
user_pref("browser.cache.memory.enable", false); //very usefull if you have < 4GB RAM
user_pref("browser.helperApps.deleteTempFileOnExit", true);
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
user_pref("browser.sessionhistory.max_entries", 10);
user_pref("browser.sessionstore.interval", 600000); //less writes to ssd
//user_pref("browser.sessionstore.resume_from_crash", false);
//user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.urlbar.placeholderName", "DuckDuckGo");
user_pref("device.sensors.enabled", false);
//user_pref("dom.maxHardwareConcurrency", 1); //faster on slow devices
user_pref("dom.battery.enabled", false);
user_pref("dom.event.clipboardevents.enabled", false);
user_pref("dom.indexedDB.enabled", false);
user_pref("dom.webaudio.enabled", false);
user_pref("experiments.activeExperiment", false);
user_pref("experiments.enabled", false);
user_pref("experiments.manifest.uri", "");
user_pref("experiments.supported", false);
user_pref("dom.event.highrestimestamp.enabled", false);
user_pref("dom.telephony.enabled", false);
user_pref("dom.netinfo.enabled", false);
user_pref("dom.webnotifications.enabled", false);
user_pref("dom.webnotifications.serviceworker.enabled", false);
user_pref("dom.serviceWorkers.enabled", false);
user_pref("dom.vibrator.enabled", false);
user_pref("dom.enable_resource_timing", false);
user_pref("geo.enabled", false);
user_pref("geo.provider.ms-windows-location", false);
user_pref("geo.provider.use_corelocation", false);
user_pref("geo.provider.use_gpsd", false);
user_pref("javascript.options.mem.max", 128000);
user_pref("javascript.options.mem.high_water_mark", 32);
user_pref("media.autoplay.default", 1);
user_pref("media.autoplay.enabled", false);
user_pref("media.video_stats.enabled", false);
user_pref("network.cookie.lifetime.days", 1);
user_pref("network.cookie.cookieBehavior", 1);
user_pref("network.cookie.lifetimePolicy", 2);
user_pref("network.cookie.thirdparty.sessionOnly", true);
//user_pref("network.proxy.type", 0);
user_pref("network.prefetch-next", false);
user_pref("network.trr.mode", 2); // change to 3 to enforce dns over https
//other network.trr.uri to try:
// https://dns9.quad9.net/dns-query
// https://doh.cleanbrowsing.org/doh/adult-filter/
// https://mozilla.cloudflare-dns.com/dns-query
// https://cloudflare-dns.com/dns-query
user_pref("network.trr.uri", "https://doh.cleanbrowsing.org/doh/adult-filter/");  //https://cleanbrowsing.org/dnsoverhttps
user_pref("browser.newtab.preload", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
user_pref("browser.newtabpage.enhanced", false);
//user_pref("privacy.firstparty.isolate", true);
user_pref("privacy.clearOnShutdown.cache", true);
//user_pref("privacy.clearOnShutdown.cookies", true);
//user_pref("privacy.clearOnShutdown.downloads", true);
//user_pref("privacy.clearOnShutdown.formdata", true);
//user_pref("privacy.clearOnShutdown.history", true);
user_pref("privacy.clearOnShutdown.offlineApps", true);
//user_pref("privacy.clearOnShutdown.sessions", true);
//user_pref("privacy.clearOnShutdown.openWindows", true);
user_pref("privacy.cpd.cache", true);
user_pref("privacy.resistFingerprinting", true);
user_pref("privacy.sanitize.pending", "[{\"id\":\"shutdown\",\"itemsToClear\":[\"cache\",\"offlineApps\"],\"options\":{}}]");
//user_pref("privacy.sanitize.pending", "[{\"id\":\"shutdown\",\"itemsToClear\":[\"cache\",\"cookies\",\"offlineApps\",\"formdata\",\"sessions\",\"siteSettings\"],\"options\":{}}]");
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.pbmode.enabled", true);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("webgl.disabled, true);
