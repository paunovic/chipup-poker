with import ./default.nix;
{
 inherit generator tests test-driver;
 server = server.package;
}
