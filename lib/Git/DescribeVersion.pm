package Git::DescribeVersion;
# ABSTRACT: Use git-describe to determine a git repo's version

=head1 SYNOPSIS

	use Git::DescribeVersion ();
	Git::DescribeVersion->new('.', {opt => 'value'});

Or this one-liner:

	perl -MGit::DescribeVersion::App -e run

=cut

use strict;
use warnings;

use Git::Wrapper;
use version 0.77 ();

our %Defaults = (
	first_version 	=> 'v0.1',
	match_pattern 	=> 'v[0-9]*',
#	count_format 	=> 'v0.1.%d',
	version_regexp 	=> '^v(.+)$'
);

# TODO: attribute for returning dotted-decimal

sub new {
	my ($class, $git, $attr) = @_;
	my $self = {
		git => (ref($git) ? $git : Git::Wrapper->new($git)),
		%Defaults,
		%$attr
	};
	bless $self, $class;
}

sub version {
	my ($self) = @_;
	return $self->version_from_describe() ||
		$self->version_from_count_objects();
}

sub parse_version {
  my ($self, $prefix, $count) = @_;
  # quote 'version' to reference the module and not call the local sub
  return 'version'->parse("v$prefix.$count")->numify;
    #if $vstring =~ $version::LAX;
}

sub version_from_describe {
	my ($self) = @_;
	my ($ver) = eval {
		$self->{git}->describe(
			{match => $self->{match_pattern}, tags => 1, long => 1}
		);
	} or return undef;

	# ignore the -gSHA
	my ($tag, $count) = ($ver =~ /^(.+?)-(\d+)-(g[0-9a-f]+)$/);
	$tag =~ s/$self->{version_regexp}/$1/;

	return $self->parse_version($tag, $count);
}

sub version_from_count_objects {
	my ($self) = @_;
	my @counts = $self->{git}->count_objects({v => 1});
	my $count = 0;
	local $_;
	foreach (@counts){
		/(count|in-pack): (\d+)/ and $count += $2;
	}
	return $self->parse_version($self->{first_version}, $count);
}

1;

=head1 OPTIONS

These options can be passed to C<new()>:

=head2 first_version

If the repository has no tags at all, this version
is used as the first version for the distribution.  It defaults to "v0.1".
Then git objects will be counted and appended to create a version like "v0.1.5".

=head2 version_regexp

Regular expression that matches a tag containing
a version.  It must capture the version into $1.  Defaults to C<^v([0-9._]+)$>
which matches tags like C<"v0.1">.

=head2 match_pattern

A shell-glob-style pattern to match tags
(default "v[0-9]*").  This is passed to C<git-describe> to help it
find the right tag to count commits from.

=head1 SEE ALSO

=for :list
* C<git>: L<http://www.git-scm.com|git>
* L<Git::Wrapper>