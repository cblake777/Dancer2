use Test::More tests => 9;
use strict;
use warnings;
use File::Spec;
use File::Temp 0.22;

use Dancer::FileUtils qw/read_file_content path_or_empty/;

sub write_file {
    my ($file, $content) = @_;

    open CONF, '>', $file or die "cannot write file $file : $!";
    print CONF $content;
    close CONF;
}

sub hexe {
    my $s = shift;
    $s =~ s/([\x00-\x1F])/sprintf('%#x',ord($1))/eg;
    return $s;
}

eval { Dancer::FileUtils::open_file('<', '/slfkjsdlkfjsdlf') };
like $@, qr{/slfkjsdlkfjsdlf' using mode '<'};

my $content = Dancer::FileUtils::read_file_content();
is $content, undef;

is Dancer::FileUtils::normalize_path(), undef;

my $p = Dancer::FileUtils::dirname('/somewhere');
is $p, '/';

my $tmp = File::Temp->new();
write_file($tmp, "one$/two");

$content = read_file_content($tmp);
is hexe($content), hexe("one$/two");

my @content = read_file_content($tmp);
is hexe($content[0]), hexe("one$/");
is $content[1], 'two';

# returns UNDEF on non-existant path
my $path = 'bla/blah';
if (! -e $path) {
    is(
        path_or_empty($path),
        '',
        'path_or_empty on non-existent path',
    );
}

is(path_or_empty('/tmp'), '/tmp');
