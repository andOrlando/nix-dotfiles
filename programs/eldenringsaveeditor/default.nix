{ lib, python3Packages, fetchFromGitHub }:
with python3Packages;
buildPythonApplication {
  pname = "Elden Ring Save Manager";
  version = "v1.65";
  src = fetchFromGitHub {
    owner = "Ariescyn";
    repo = "EldenRing-Save-Manager";
    rev = "v1.65";
    sha256 = "sha256-bgxXaaaSs1ua8tmfdwFq09mG2YShHu4/bOBSStbjlP0=";
  };
  nativeBuildInputs = [
    pillow
    requests
  ];
}
