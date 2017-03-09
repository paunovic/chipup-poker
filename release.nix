with import ./default.nix;
{
 inherit generator tests test-driver client;
 server = server.package;
}
