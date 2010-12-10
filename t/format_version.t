use strict;
use warnings;
use Test::More;
use version;

my $vobject = version->parse('v1.2.3');

my %tests = (
	'v1.2.3' => [qw(
		dotted
		normal
		v-string
		v
		dot
		string
		ov
	)],
	'1.2.3' => [qw(
		no-v-string
		no-vstring
		no-v
		no_v
		no+vstring
		novstring
		nov
	)],
	'1.002003' => [qw(
		decimal
		default
		compatible
		pirate
	)]
);

plan tests => (map { @$_ } values %tests) + 2; # tests + (require + isa)

my $mod = 'Git::DescribeVersion';
require_ok($mod);
my $gdv = $mod->new();
isa_ok($gdv, $mod);

foreach my $version ( keys %tests ){
	foreach my $format ( @{$tests{$version}} ){
		$gdv->{format} = $format;
		is($gdv->format_version($vobject), $version, "format '$format' produces version '$version'");
	}
}