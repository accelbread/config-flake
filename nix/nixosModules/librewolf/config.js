// Copyright (C) Archit Gupta <archit@accelbread.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
(function() {
  const config = @config@;

  (function() {
    function set(pref, val) {
      if(typeof val === "object") {
        val = JSON.stringify(val);
      }
      defaultPref(pref, val);
      clearPref(pref);
    }

    set("identity.fxaccounts.account.device.name",
      `${Services.dns.myHostName} ${Services.appinfo.name}`);

    Object.entries(config.prefs).forEach(([k, v]) => set(k, v));
  }());

  const { AddonManager } = ChromeUtils.importESModule(
    "resource://gre/modules/AddonManager.sys.mjs"
  );
  const { CanonicalJSON } = ChromeUtils.importESModule(
    "resource://gre/modules/CanonicalJSON.sys.mjs"
  );

  async function configureExtension(extension) {
    const extensionSettings = config.extensions;

    const settings = extensionSettings[extension.id];
    if (!settings?.local && !settings?.sync) {
      return;
    }
    try {
      const storage = extension.apiManager
        .getAPI("storage", extension, "addon_parent")
        .getAPI({ extension }).storage;
      const storageCalls = {
        local: (method, value) =>
          storage.local.callMethodInParentProcess(method, [value]),
        sync: (method, value) => storage.sync[method](value)
      };
      let changed = false;
      for (const [area, callStorage] of Object.entries(storageCalls)) {
        const declared = settings[area] ?? {};
        const keys = Object.keys(declared);
        if (keys.length === 0) {
          continue;
        }
        const current = await callStorage("get", keys);
        const changes = Object.fromEntries(
          Object.entries(declared).filter(
            ([key, value]) =>
              !Object.hasOwn(current, key) ||
              CanonicalJSON.stringify(current[key]) !==
                CanonicalJSON.stringify(value)
          )
        );
        if (Object.keys(changes).length === 0) {
          continue;
        }
        changed = true;
        await callStorage("set", changes);
      }
      if (changed) {
        const addon = await AddonManager.getAddonByID(extension.id);
        await addon.reload();
      }
    } catch (error) {
      Components.utils.reportError(error);
    }
  }

  async function configureExtensions() {
    await AddonManager.readyPromise;
    const { XPIExports } = ChromeUtils.importESModule(
      "resource://gre/modules/addons/XPIExports.sys.mjs"
    );
    const { XPIProvider } = XPIExports;
    const { ExtensionParent } = ChromeUtils.importESModule(
      "resource://gre/modules/ExtensionParent.sys.mjs"
    );
    await Promise.allSettled([
      ...XPIProvider.startupPromises,
      ...XPIProvider.enabledAddonsStartupPromises
    ]);
    await Promise.all(
      [...ExtensionParent.GlobalManager.extensionMap.values()]
        .filter(extension => extension.policy?.active)
       .map(extension => configureExtension(extension))
    );
  }

  configureExtensions().catch(error => Components.utils.reportError(error));
}());
