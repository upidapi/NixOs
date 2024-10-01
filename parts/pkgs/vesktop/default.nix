{vesktop, ...}:
vesktop.overrideAttrs (old: {
  patches =
    (old.patches or [])
    ++ [
      ./fix-readonly.patch
      ./remove-splash.patch
      ./tray-notifications.patch
    ];

  pnpmDeps = old.pnpmDeps.overrideAttrs {
    outputHash = "sha256-ERaKH1r5chZeK2HvztD3xFwLvyakMJT9uM6IQiej6t4=";
  };
})
