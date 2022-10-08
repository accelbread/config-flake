pkgs:
builtins.mapAttrs (k: v: {
  type = "app";
  program = "${pkgs.writeShellApplication {
    name = k;
    runtimeInputs = v.runtimeInputs or [ ];
    inherit (v) text;
  } + "/bin/" + k}";
}) { }

