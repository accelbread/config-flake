{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption mkPackageOption types mkIf;
  cfg = config.services.rnnoise;
  label = "noise_suppressor_" + (if cfg.stereo then "stereo" else "mono");
  targetStr =
    if cfg.target != null then ''node.target = "${cfg.target}"''
    else "";
in
{
  options.services.rnnoise = {
    enable = mkEnableOption cfg.package.meta.description;
    package = mkPackageOption pkgs "rnnoise-plugin" { };
    vadThreshold = mkOption {
      type = types.number;
      default = 50.0;
      description = "Voice probability under which audio will be silenced.";
    };
    vadGracePeriod = mkOption {
      type = types.int;
      default = 200;
      description = "Duration (ms) to prevent silencing after last detection.";
    };
    retroactiveVadGracePeriod = mkOption {
      type = types.int;
      default = 0;
      description = "Duration (ms) to prevent silencing before next detection.";
    };
    stereo = mkOption {
      type = types.bool;
      default = false;
      description = "Enable stereo output.";
    };
    target = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Device to read from.";
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."pipewire/pipewire.conf.d/99-input-denoising.conf".text = ''
      context.modules = [{
        name = libpipewire-module-filter-chain
        args = {
          node.description = "RNNoise"
          media.name = "RNNoise"
          filter.graph = {
            nodes = [{
              type = ladspa
              name = rnnoise
              plugin = ${cfg.package}/lib/ladspa/librnnoise_ladspa.so
              label = ${label}
              control = {
                "VAD Threshold (%)" = ${toString cfg.vadThreshold}
                "VAD Grace Period (ms)" = ${toString cfg.vadGracePeriod}
                "Retroactive VAD Grace (ms)" = ${toString
                  cfg.retroactiveVadGracePeriod}
              }
            }]
          }
          capture.props = {
            node.name = "capture.rnnoise_source"
            node.description = "RNNoise capture"
            node.passive = true
            ${targetStr}
            audio.rate = 48000
          }
          playback.props = {
            node.name = "rnnoise_source"
            media.class = Audio/Source
            audio.rate = 48000
          }
        }
      }]
    '';
  };
}
