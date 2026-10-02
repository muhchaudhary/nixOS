# OpenLDAP's syncrepl test can be flaky in some environments.
final: prev: {
  openldap = prev.openldap.overrideAttrs (_: {
    doCheck = false;
  });
}
