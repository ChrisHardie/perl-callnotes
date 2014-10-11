#!/usr/bin/perl

=head1 NAME

callnotes.pl - quickly create and open a notes file, for use with Alfred or other tools

=head1 SYNOPSIS

    # callnotes.pl --notes_dir /my/notes/dir --desc "String describing call subject"

=head1 DESCRIPTION

This simple script quickly creates and opens for editing a text file, named based on the current date and a descriptive string passed via the command line.

It was created to be a part of an L<Alfred|http://www.alfredapp.com/> workflow for easy triggering via a keyword.

For example, typing "cn New Client" in the Alfred hotkey input field would open the file 20141011-new-client.txt for editing.

=head1 REQUIREMENTS

Perl

L<Unicode::Normalize>

Alfred (optional)

=head1 LICENSE

This program is free software; anyone can use, redistribute, and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation (either version 2 of the
License, or at your option, any later version) so long as this notice
and the copyright information above remain intact and unchanged.
Selling this code in any form for any reason is expressly forbidden.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this software; if not, write to
        Free Software Foundation, Inc., 59 Temple Place, Suite 330,
        Boston, MA  02111-1307 USA
You may also find the license at:
        http://www.gnu.org/copyleft/gpl.html

=head1 AUTHOR

Chris Hardie <chris@chrishardie.com>

http://www.chrishardie.com/

=cut

use POSIX qw/strftime/;
use Unicode::Normalize;
use Getopt::Long;
use strict;

# Default destination directory, no trailing slash
my $notes_dir = "/Users/chris/mynotes";

# Default file extension
my $notes_ext = "txt";

# Default notes description (doesn't really make sense to set anything here)
my $description = '';

# Date prefix for better organization, YYYYMMDD
my $date_prefix = strftime('%Y%m%d', localtime);

######################################################
# You shouldn't need to change anything below this unless you know what
# you're doing.

sub slugify($);

GetOptions(
    'notes_dir=s' => \$notes_dir,
    'notes_ext=s' => \$notes_ext,
    'desc=s' => \$description,
);

die "Usage: $0 --notes_dir /my/directory --desc \"my description\"\n"
    unless $notes_dir && $description;

my $slug = slugify($description);

my $full_path = "$notes_dir/$date_prefix-$slug.$notes_ext";

# If the file already exists, die
if (-e $full_path) {

    die "File exists, won't overwrite: $full_path\n";

# If we can't write to the directory, die
} elsif (! -w $notes_dir) {

    die "Can't write to $notes_dir\n";

} else {

    open(NOTES, ">$full_path") || die "Can't create $full_path: $!\n";

    print NOTES "Call notes for $description\n";
    print NOTES strftime('%a %b %d, %Y at %H:%M', localtime) . "\n";
    print NOTES "=" x 40;
    print NOTES "\n\n";

    close NOTES;

}

# On OS X, open the file using the default text editor for that file type
`open $full_path`;

exit;

# Take a string and turn it into a slug-friendly format
# Thanks to Cameron, http://stackoverflow.com/a/4009519
sub slugify($) {
    my ($input) = @_;

    $input = NFKD($input);         # Normalize the Unicode string
    $input =~ tr/\000-\177//cd;    # Strip non-ASCII characters (>127)
    $input =~ s/[^\w\s-]//g;       # Remove all characters that are not word characters (includes _), spaces, or hyphens
    $input =~ s/^\s+|\s+$//g;      # Trim whitespace from both ends
    $input = lc($input);
    $input =~ s/[-\s]+/-/g;        # Replace all occurrences of spaces and hyphens with a single hyphen

    return $input;
}