use strict;
use warnings;
use Test::More;
use lib 't/lib';
use GitDVTest;

plan tests => @commits * @versions * 3 + 1; # commits * versions * formats + isa

my $mock = mock_gw;
use Git::DescribeVersion;
my $gv = Git::DescribeVersion->new(git_wrapper => $mock);
isa_ok($gv, 'Git::DescribeVersion');

foreach my $commits ( @commits ){
	$mock->set_series('describe', map { ("$$_[0]-${commits}-gdeadbeef") x 3 } @versions);
	foreach my $version ( @versions ){
	test_expectations($gv, $version, $commits, sub {
		my ($exp, $desc) =  @_;
		is($gv->version, $exp, $desc);
	});
	}
}
