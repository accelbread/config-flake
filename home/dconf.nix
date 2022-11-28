{ lib, pkgs, ... }: {
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri =
        "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      picture-uri-dark =
        "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-d.jpg";
      primary-color = "#3465a4";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "terminate:ctrl_alt_bksp" "compose:caps" ];
    };
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      font-antialiasing = "rgba";
      font-hinting = "slight";
      locate-pointer = true;
    };
    "org/gnome/desktop/media-handling" = { autorun-never = true; };
    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
      remember-recent-files = false;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
    };
    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      lock-delay = mkUint32 30;
      picture-options = "zoom";
      picture-uri =
        "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      primary-color = "#3465a4";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/session" = { idle-delay = mkUint32 180; };
    "org/gnome/desktop/wm/preferences" = { resize-with-right-button = true; };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = mkUint32 4226;
    };
    "org/gnome/nautilus/preferences" = { show-delete-permanently = true; };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        native-window-placement.extensionUuid
        espresso.extensionUuid
        system-action-hibernate.extensionUuid
        gsconnect.extensionUuid
      ];
      favorite-apps = [
        "emacs.desktop"
        "librewolf.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };
    "org/gnome/system/location" = { enabled = true; };
    "org/gtk/settings/file-chooser" = { clock-format = "12h"; };
    "org/gnome/shell/extensions/gsconnect" = {
      enabled = true;
      devices = [ "ac748f01c50c470d" ];
    };
    "org/gnome/shell/extensions/gsconnect/device/ac748f01c50c470d" = {
      name = "Pixel 6";
      type = "phone";
      paired = true;
      certificate-pem = ''
        -----BEGIN CERTIFICATE-----
        MIIC9zCCAd+gAwIBAgIBATANBgkqhkiG9w0BAQsFADA/MRkwFwYDVQQDDBBhYzc0
        OGYwMWM1MGM0NzBkMRQwEgYDVQQLDAtLREUgQ29ubmVjdDEMMAoGA1UECgwDS0RF
        MB4XDTIxMDkyMjA3MDAwMFoXDTMxMDkyMjA3MDAwMFowPzEZMBcGA1UEAwwQYWM3
        NDhmMDFjNTBjNDcwZDEUMBIGA1UECwwLS0RFIENvbm5lY3QxDDAKBgNVBAoMA0tE
        RTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANPJP0mrP9kPBVzDsHDh
        MyRguRYAfnY7vLSpsfOPBmzYJ4X+HhSuXKpRRpcDm39IJxZMbfbPx+gq87xLBQ8q
        f7jR5RYJVjHxAgXOkkQ2RZFpe1CZ5YLCQeSDXGQmSpWDulvzxUMzCzNzOCGYmGOT
        43Zf1rBvXACwq5CG0p+BS1RMdG5ghyonPgrfxpunPwoI0fs7+PgXYebPD1mtvxqf
        jtiZahKPRTCdlqeDGFZ16sJIFbM7igElUjCdR2auiJPkP/8LYYEkIKeTHmCYxGmR
        N7pHkyA4yeu/dttqe5YlWJsnwSWqaKLEYxfVk2s4NuQZM4UX3bJTMo4W/ZFh6Dmh
        WtUCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAKO7yaEVh1Wq/mTqFIFq5h5qifeN9
        TaWSJyCnvY4iee/toQXmqSqaadGv92IpEEx2Pz7d3lBQDuV34g1PzBEo5M24AW6k
        RO7k9Wkg7B+Il/ufY5Tg6bIZGJGXt7hnWOY8jJiAddexYf9cdSuCw2mvS8yy1Suv
        ntV7q3XQxIidf+ftdTRMMmffOvaLh0U6YRBVpoYImYsrPyaQ9kErv/8P7tnWug+l
        OmMmqiUsKEIJ7xO5sUmvctVnKvOSm8dgMnF0GW8vu74lPpRbIuBv+74WuIPjFGs8
        kN/8Dk1L3ErshiqBy4S39UlgVF75nGXRbAmX/AJOewfuVEPScZ1iGx27Vg==
        -----END CERTIFICATE-----
      '';
      disabled-plugins = [ "clipboard" ];
      incoming-capabilities = [
        "kdeconnect.battery"
        "kdeconnect.battery.request"
        "kdeconnect.bigscreen.stt"
        "kdeconnect.clipboard"
        "kdeconnect.clipboard.connect"
        "kdeconnect.connectivity_report.request"
        "kdeconnect.contacts.request_all_uids_timestamps"
        "kdeconnect.contacts.request_vcards_by_uid"
        "kdeconnect.findmyphone.request"
        "kdeconnect.mousepad.keyboardstate"
        "kdeconnect.mousepad.request"
        "kdeconnect.mpris"
        "kdeconnect.mpris.request"
        "kdeconnect.notification"
        "kdeconnect.notification.action"
        "kdeconnect.notification.reply"
        "kdeconnect.notification.request"
        "kdeconnect.photo.request"
        "kdeconnect.ping"
        "kdeconnect.runcommand"
        "kdeconnect.sftp.request"
        "kdeconnect.share.request"
        "kdeconnect.share.request.update"
        "kdeconnect.sms.request"
        "kdeconnect.sms.request_attachment"
        "kdeconnect.sms.request_conversation"
        "kdeconnect.sms.request_conversations"
        "kdeconnect.systemvolume"
        "kdeconnect.telephony.request"
        "kdeconnect.telephony.request_mute"
      ];
      outgoing-capabilities = [
        "kdeconnect.battery"
        "kdeconnect.battery.request"
        "kdeconnect.bigscreen.stt"
        "kdeconnect.clipboard"
        "kdeconnect.clipboard.connect"
        "kdeconnect.connectivity_report"
        "kdeconnect.contacts.response_uids_timestamps"
        "kdeconnect.contacts.response_vcards"
        "kdeconnect.findmyphone.request"
        "kdeconnect.mousepad.echo"
        "kdeconnect.mousepad.keyboardstate"
        "kdeconnect.mousepad.request"
        "kdeconnect.mpris"
        "kdeconnect.mpris.request"
        "kdeconnect.notification"
        "kdeconnect.notification.request"
        "kdeconnect.photo"
        "kdeconnect.ping"
        "kdeconnect.presenter"
        "kdeconnect.runcommand.request"
        "kdeconnect.sftp"
        "kdeconnect.share.request"
        "kdeconnect.sms.attachment_file"
        "kdeconnect.sms.messages"
        "kdeconnect.systemvolume.request"
        "kdeconnect.telephony"
      ];
      supported-plugins = [
        "battery"
        "clipboard"
        "connectivity_report"
        "contacts"
        "findmyphone"
        "mousepad"
        "mpris"
        "notification"
        "photo"
        "ping"
        "presenter"
        "runcommand"
        "sftp"
        "share"
        "sms"
        "systemvolume"
        "telephony"
      ];
    };
  };
}
