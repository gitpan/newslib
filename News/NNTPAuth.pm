$VERSION = "0.5b";
# -*- Perl -*-
###############################################################################
# Written by Tim Skirvin <tskirvin@killfile.org>
# Copyright 2000, Tim Skirvin.  Redistribution terms are below.
###############################################################################

=head1 NAME

News::NNTPAuth - a standard NNTP authentication method

=head1 SYNOPSIS

  use News::NNTPAuth;
  my ($nntpuser, $nntppass) = News::NNTPAuth->nntpauth($server->server);

  use Net::NNTP;
  my $nntp = new Net::NNTP;
  $nntp->authinfo($nntpuser, $nntppass);

=head1 DESCRIPTION

NNTP authentication is a standard feature of most news servers nowadays,
though many news readers have yet to catch up.  When writing your own news
reader, though, you have to keep track of this data separately, unless you
have a standardized place to store the information - like this module.

This module offers a few functions which parse the local ~/.nntpauth file
and return the appropriate data.  This file contains lines that look like
this:

SERVER	USER	PASSWORD

That's it.  The functions are called by offering forth a C<SERVER>, and
the first user/password pair in the file is returned.  These values can
then be passed into Net::NNTP's B<nntpauth()> function.

=cut

package News::NNTPAuth;

use strict;
use Exporter;
use vars qw( $NNTPAUTH $DEBUG $VERSION );

$NNTPAUTH = "$ENV{'HOME'}/.nntpauth";
$DEBUG    = 0;

=head1 METHODS

=over 4

=item nntpauth ( SERVER ) 

Parses ~/.nntpauth for the given C<SERVER>.  Returns two items - the user 
name and the password.  If one or both of these is not found, then the
appropriate value is set to 'undef'.

=cut

sub nntpauth {
  my ($class, $server) = @_;  	return (undef, undef) unless $server;
  warn "Trying to get auth information for $server\n" if $DEBUG;
  return (undef, undef) unless (-r $NNTPAUTH);
  my ($nntpuser, $nntppass);
  open (CONFIG, "<$NNTPAUTH") 
	or warn "Couldn't open $NNTPAUTH: $@" && return undef;
  while (<CONFIG>) {
    chomp;  
    if (/^\s*(\S+)\s+(\S+)\s+(\S+)\s*$/) {
      my $serv = $1;  my $user = $2;  my $pass = $3;
      $nntpuser = $user if ($serv =~ /^$server$/i);
      $nntppass = $pass if ($serv =~ /^$server$/i);
    }
  }
  close (CONFIG);
  ($nntpuser || undef, $nntppass || undef);
}

=item nntpuser ( SERVER )

=item nntppass ( SERVER )

Invokes B<nntpauth()>, and returns the appropriate item from the list -
the user name for B<nntpuser()>, or the password for B<nntppass()>.

=back

=cut

sub nntpuser { @{nntpauth(@_)}[0] }
sub nntppass { @{nntpauth(@_)}[1] }

=head1 NOTES

Please note that this is an extremely small module.  The only real 
purpose is to standardize on the ~/.nntpauth format that I've been 
using for a long time.  It's convenient.  Why not?

=head1 TODO

Put this in CPAN.  Maybe.  It is awfully small.  Maybe it would be best if
I made it a part of a news library module instead...

=head1 AUTHOR

Written by Tim Skirvin <tskirvin@killfile.org>

=head1 COPYRIGHT

Copyright 2000 by Tim Skirvin <tskirvin@killfile.org>.  This code may be
redistributed under the same terms as Perl itself.

=cut


1;
