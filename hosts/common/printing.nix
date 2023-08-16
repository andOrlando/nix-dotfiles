{
  # printing stuff
  services.printing.enable = true;
  services.printing.cups-pdf.enable = true;
  services.printing.cups-pdf.instances.bennettpdf.settings = {
    Out = "\${HOME}/Documents";
  };
  hardware.printers.ensureDefaultPrinter = "bennettpdf";
  hardware.opentabletdriver.enable = true;
}