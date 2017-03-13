with import ./default.nix;
{
 inherit generator tests test-driver client "x86_64-darwin";
 server = server.package;
}
