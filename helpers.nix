lib:
{
  mkStringDefaults = attrs: lib.attrsets.mapAttrs (name: value: 
    lib.mkOption {
      type = lib.types.str;
      default = value;
    }
  ) attrs;
}
