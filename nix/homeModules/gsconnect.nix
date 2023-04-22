{ pkgs, lib, config, nixosConfig, ... }:
let
  inherit (lib) mkMerge mkIf;
  inherit (nixosConfig.networking) hostName;
in
mkMerge [
  {
    dconf.settings = {
      "org/gnome/shell/extensions/gsconnect" = {
        name = hostName;
        enabled = true;
      };
    };
  }
  {
    dconf.settings = {
      "org/gnome/shell/extensions/gsconnect" = {
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
  (mkIf (hostName == "solace") {
    dconf.settings = {
      "org/gnome/shell/extensions/gsconnect" = {
        id = "0acf5e7b-de24-425b-8cb9-ab00a8c5bc7f";
      };
    };
  })
  (mkIf (hostName != "solace") {
    dconf.settings = {
      "org/gnome/shell/extensions/gsconnect" = {
        devices = [ "0acf5e7b-de24-425b-8cb9-ab00a8c5bc7f" ];
      };
      "org/gnome/shell/extensions/gsconnect/device/0acf5e7b-de24-425b-8cb9-ab00a8c5bc7f" = {
        name = "solace";
        type = "desktop";
        paired = true;
        certificate-pem = ''
          -----BEGIN CERTIFICATE-----
          MIIFpTCCA42gAwIBAgIUBzIG/gBMGw3GHRVBQec6E8clLlswDQYJKoZIhvcNAQEL
          BQAwYjEdMBsGA1UECgwUYW5keWhvbG1lcy5naXRodWIuaW8xEjAQBgNVBAsMCUdT
          Q29ubmVjdDEtMCsGA1UEAwwkMGFjZjVlN2ItZGUyNC00MjViLThjYjktYWIwMGE4
          YzViYzdmMB4XDTIyMTEyODAyMjAwMFoXDTMyMTEyNTAyMjAwMFowYjEdMBsGA1UE
          CgwUYW5keWhvbG1lcy5naXRodWIuaW8xEjAQBgNVBAsMCUdTQ29ubmVjdDEtMCsG
          A1UEAwwkMGFjZjVlN2ItZGUyNC00MjViLThjYjktYWIwMGE4YzViYzdmMIICIjAN
          BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAq9waBP7LvVZNB+2GHM1GwQkumjpm
          R+S+I28bGahLs8KcTLIrWsxvDI/BFPlQLOKwOJTnPiFcPY8vuG43oOdKSajpfmHA
          LBfbJUIXuvOb020THq8OsiR4nYT/HoC8XeLLAySzfF2V2Tc0upqzyeZcJR2m2EB0
          4Kz2kjV57M3iWqLj+IcDl7uHr+2JEUSLnX99zsKlsRX2vhj4jCBjHFU+zhTULoeJ
          V/ojwEi0NYk0E+P4HYZepwvkEIHbShvsRh5Z4gftDXT7OsqP6+NIvA+rQRk5yGRv
          wof2p/xJmfHKoQmOZfNuSOblV+isJRgKL7PiwrR5LhI1JzQ9lr3W6bOYZ8Cs0k22
          CrzVT4PIOrELHql4qvqIzeYn1ZP46UdCs3IXeSsnRclgx/RfnlDtyu/oouKnTrXF
          tM2iTPzJOTShHrWIceF1KaGO6vnpdOVDdWzI0vFn7mEhXJtOYHy3cu0Nh+QGAdMA
          zoQaMAzUnZgEV0zTTUpBHDMso7Lh+htqv9g7mHMqumGRZM+cUZUFcMlTdYZljmqQ
          nOXVCmfG8dDMv3yHi1jZwa9cM3cIYohqCUJnWmupR//+LTXzOZP+tD17NXUD101I
          Fl99JS/S/Y8bF0t+yei4+yvQAQzFoHudFULcdf4mky9xFv4oFYt1INw47RwEcyp2
          vQGkKTgPpHjfZ+cCAwEAAaNTMFEwHQYDVR0OBBYEFG4LDu8S+mDYjdJ3aRSiAAPR
          TNZ8MB8GA1UdIwQYMBaAFG4LDu8S+mDYjdJ3aRSiAAPRTNZ8MA8GA1UdEwEB/wQF
          MAMBAf8wDQYJKoZIhvcNAQELBQADggIBAH1mDYTvAIioYH5zMzapY1L2Qb8iofJC
          9Ifpk45XTKE+fkiM7HzZaGMHYLEF7Pew+U2lACFsdZoLO0AJf9NUuPx8TwdX4Ona
          mQTiz3ZdWXsVhg44D1yzQD5e9hQ/kp+Rslcb2Cqa0eG+o6ZD12gERGRA3v2/dfBh
          uPHTCUCBoOmYrlDjgoiritikzw9opMVC1HIG4LJu7/qEaP25OFhurI3374tl+wMI
          npq9HsxgBJgRQ9t+hFoKY3yBm1ZTcDAYIjaUT/uW/j2Q9T72RBy9L7czZtRxSPFm
          Rv905fVA0kcBoGAmqmSY63IXvt8BVsQ5MJZ41lb52MtnciehqlYwMZ6+0H9T/dpM
          MwPj2SK7txGiZV/WqGBOBhefGEBejow9kHrE7rbvYf2xZXDfXCUEIRjb26J5dVna
          qbFGvFx21eXDo9OFuW5OI0RZMIHSAAKeAHUOtJFN78XY8zXs8yhI1s3sK11Sw8qg
          ur+KBIlYytsr7M+u/YGL2kAX8iXnW67lA/FTIHi8x+0VUGBrMrErudXNq411Vt65
          AKmTZSMmeqkSJiPYerW6NHpHNboK5NGOp4krD4WtmPrieZh2VdNHGMiIjKLTOUsC
          Af3alLwYkQ1Wom/zK84bDGmyT72YGXom9zzb9MjuLeHTb4gepWhjB0PBg2XfE6uM
          G21VOhZ3qMZD
          -----END CERTIFICATE-----
        '';
        incoming-capabilities = [
          "kdeconnect.battery"
          "kdeconnect.battery.request"
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
          "kdeconnect.photo.request"
          "kdeconnect.ping"
          "kdeconnect.presenter"
          "kdeconnect.runcommand"
          "kdeconnect.runcommand.request"
          "kdeconnect.sftp"
          "kdeconnect.share.request"
          "kdeconnect.sms.messages"
          "kdeconnect.systemvolume.request"
          "kdeconnect.telephony"
        ];
        outgoing-capabilities = [
          "kdeconnect.battery"
          "kdeconnect.battery.request"
          "kdeconnect.clipboard"
          "kdeconnect.clipboard.connect"
          "kdeconnect.connectivity_report.request"
          "kdeconnect.contacts.request_all_uids_timestamps"
          "kdeconnect.contacts.request_vcards_by_uid"
          "kdeconnect.findmyphone.request"
          "kdeconnect.mousepad.echo"
          "kdeconnect.mousepad.keyboardstate"
          "kdeconnect.mousepad.request"
          "kdeconnect.mpris"
          "kdeconnect.mpris.request"
          "kdeconnect.notification"
          "kdeconnect.notification.action"
          "kdeconnect.notification.reply"
          "kdeconnect.notification.request"
          "kdeconnect.photo"
          "kdeconnect.photo.request"
          "kdeconnect.ping"
          "kdeconnect.runcommand"
          "kdeconnect.runcommand.request"
          "kdeconnect.sftp.request"
          "kdeconnect.share.request"
          "kdeconnect.sms.request"
          "kdeconnect.sms.request_conversation"
          "kdeconnect.sms.request_conversations"
          "kdeconnect.systemvolume"
          "kdeconnect.telephony.request"
          "kdeconnect.telephony.request_mute"
        ];
        supported-plugins = [
          "battery"
          "clipboard"
          "findmyphone"
          "mousepad"
          "mpris"
          "notification"
          "photo"
          "ping"
          "runcommand"
          "share"
        ];
      };
    };
  })
  (mkIf (hostName == "shadowfang") {
    dconf.settings = {
      "org/gnome/shell/extensions/gsconnect" = {
        id = "e7b312b7-01ea-4602-a520-ab95aada92f8";
      };
    };
  })
  (mkIf (hostName != "shadowfang") {
    dconf.settings = {
      "org/gnome/shell/extensions/gsconnect" = {
        devices = [ "e7b312b7-01ea-4602-a520-ab95aada92f8" ];
      };
      "org/gnome/shell/extensions/gsconnect/device/e7b312b7-01ea-4602-a520-ab95aada92f8" = {
        name = "shadowfang";
        type = "laptop";
        paired = true;
        certificate-pem = ''
          -----BEGIN CERTIFICATE-----
          MIIFpTCCA42gAwIBAgIUCEwzQIs1rgU262XGPvAbbVhYUZowDQYJKoZIhvcNAQEL
          BQAwYjEdMBsGA1UECgwUYW5keWhvbG1lcy5naXRodWIuaW8xEjAQBgNVBAsMCUdT
          Q29ubmVjdDEtMCsGA1UEAwwkZTdiMzEyYjctMDFlYS00NjAyLWE1MjAtYWI5NWFh
          ZGE5MmY4MB4XDTIyMTEyODA0MjcxMFoXDTMyMTEyNTA0MjcxMFowYjEdMBsGA1UE
          CgwUYW5keWhvbG1lcy5naXRodWIuaW8xEjAQBgNVBAsMCUdTQ29ubmVjdDEtMCsG
          A1UEAwwkZTdiMzEyYjctMDFlYS00NjAyLWE1MjAtYWI5NWFhZGE5MmY4MIICIjAN
          BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAr/EbOClhutUZdgVZIPG02qbrt/eK
          9F0kc0i5BpN7OWgefV1TL/amEFg9Y8Y7Txzz7ROdSEw3rO2BYjLQklK1mJrWWa9s
          3H/c+nOA4xB5yYgByuOyIyw2D4Ezq0rNxCxeuO3vDCEjgzmiVo2eOQUS0K4k5rs4
          9GiNNsrL4fdtW6wnWkcPn7ix/L7HsrBDLaqT5PhaKEtUBbmqaGWZshzATyj/TpWL
          TA3sDec+F7jD5wRtyXHl+Y/L5zyNfzBY0ZKqZFdVMPMOJDoU1FrnEaAwxUZovIwt
          SA8utPR+wVlDX2DBhwvB4boLY0APEXKJVvHO8C6odwWmKQL2qi654wtOHLsa1Y/j
          RaDlf1Z+Isw33KREOVFMh5xxuelaHg81IbiU9oa+209nHwJ7CUqQCpDpEgG14P+l
          NPNSSeNfwRZCY4lhnoYf6t94fKoHVmZ4V3DjIEUEvnbXgPzW7JzyYkHO+BDU6Z3C
          AvGkx8lx0HnDFA9DWld5J/6WmT6F3KbZAkfz7L1QVR77cjXcn0Gj3U4NKPiWrC3w
          skYpIbQs+IKKn7KdKwz9wMozndIvX4wmJnHGSk+pc6CgAcYMZ6+/uf46PvyVRpKJ
          PTD9EhrCCjbH8qAIDDqNC2NxbDZcOktA3m+q+z0+7sbnrF3/pVW2LZPMNBUDB965
          uSMSF2QcMEUaYhkCAwEAAaNTMFEwHQYDVR0OBBYEFBQY2AQo1pG/5Nvjrmz6P7RZ
          anUVMB8GA1UdIwQYMBaAFBQY2AQo1pG/5Nvjrmz6P7RZanUVMA8GA1UdEwEB/wQF
          MAMBAf8wDQYJKoZIhvcNAQELBQADggIBAAOdnJNosjOk/hetTSjCmtapQH2Euo8I
          aUGgla0PyWZt7xObAqcmwL3n2h6W7lxuHqQ4D365Oc00cXzu9/USvncMj5ioDQCa
          OzNceo4702kPNZlzsVEsKDuKYldebvBYbdPuUbAAXtfbTPTDszmUoAQIWtdfepH5
          QL6E2U9aXp/TPXMlBsnSknbFlyYh0C/tAEqW2WipbSLhgqMhW4rtyLcFAtmJGcYo
          qoR19dZEPTEMPsQ+8W/u2pgoY0j9XnmUn30CPWlDl0HFKj0Fd0tN+zkl0IHUqqjt
          F7wdLsR4m+zwORg9ek62iDSUA2/3Ybeb1q6JrGdFcCYWejmFc2zmMELA5tXeptYe
          hRPAoiYbarMP9khnvyhhRV9PuGF2P/dfr24lRCheYGo7OHmyZbSCpVskEYvaOPwK
          iIs9lRzEk52O6zFlQ1FdW/GebIqM4dTSsNpigaSlEQH/RqHWQP/9kAJd+zisiYsB
          hICQs1L4BpbbG1ayY/vdd6BHK5Va9Ih7m3LW6u4ZdcfJkH/JDnJKUv3ofIHaL1yN
          gk6xE/YKUP0CmsAfFHgR4ISc+29Dl5Ep/QjKli99J9gBvr2CRBTBebSr/T+imJS+
          AELKbKrYzyPKhToJ05CzSR25SJsh774KA+UKeLUEk4sAy3l9KzBnFJFL6eKYf3+7
          F8DcHazBrXYL
          -----END CERTIFICATE-----
        '';
        disabled-plugins = [ "notification" "clipboard" ];
        incoming-capabilities = [
          "kdeconnect.battery"
          "kdeconnect.battery.request"
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
          "kdeconnect.photo.request"
          "kdeconnect.ping"
          "kdeconnect.presenter"
          "kdeconnect.runcommand"
          "kdeconnect.runcommand.request"
          "kdeconnect.sftp"
          "kdeconnect.share.request"
          "kdeconnect.sms.messages"
          "kdeconnect.systemvolume.request"
          "kdeconnect.telephony"
        ];
        outgoing-capabilities = [
          "kdeconnect.battery"
          "kdeconnect.battery.request"
          "kdeconnect.clipboard"
          "kdeconnect.clipboard.connect"
          "kdeconnect.connectivity_report.request"
          "kdeconnect.contacts.request_all_uids_timestamps"
          "kdeconnect.contacts.request_vcards_by_uid"
          "kdeconnect.findmyphone.request"
          "kdeconnect.mousepad.echo"
          "kdeconnect.mousepad.keyboardstate"
          "kdeconnect.mousepad.request"
          "kdeconnect.mpris"
          "kdeconnect.mpris.request"
          "kdeconnect.notification"
          "kdeconnect.notification.action"
          "kdeconnect.notification.reply"
          "kdeconnect.notification.request"
          "kdeconnect.photo"
          "kdeconnect.photo.request"
          "kdeconnect.ping"
          "kdeconnect.runcommand"
          "kdeconnect.runcommand.request"
          "kdeconnect.sftp.request"
          "kdeconnect.share.request"
          "kdeconnect.sms.request"
          "kdeconnect.sms.request_conversation"
          "kdeconnect.sms.request_conversations"
          "kdeconnect.systemvolume"
          "kdeconnect.telephony.request"
          "kdeconnect.telephony.request_mute"
        ];
        supported-plugins = [
          "battery"
          "clipboard"
          "findmyphone"
          "mousepad"
          "mpris"
          "notification"
          "photo"
          "ping"
          "runcommand"
          "share"
        ];
      };
    };
  })
]
