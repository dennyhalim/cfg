# Lightweight Exim MX router using embedded Perl.
#
# Called from Exim as:
#   ${perl{mxroute}{$domain}}
#
# Returns:
#   mail1.example.com:mail2.example.com byname
#
# An empty string makes manualroute decline (domain is not guarded here).
# die() causes an expansion error, so Exim defers on temporary/unsafe states.
#
# Cache is process-local. Exim's resolver also provides normal DNS caching;
# this hash mainly avoids duplicate work within the same Exim process.

use strict;
use warnings;
use Socket qw(AF_INET AF_INET6 inet_pton);

my $SELF_FILE = '/etc/exim4/light-gateway-self';
my $ROUTE_TTL = 300;
my $ADDR_TTL  = 300;

my %route_cache;
my %addr_cache;
my %self_names;
my %self_ips;
my $self_loaded = 0;

sub _untaint_domain {
    my ($value) = @_;
    return undef unless defined $value;

    $value =~ s/\.$//;

    # ASCII DNS name. IDNs should already be presented as A-labels (xn--...).
    if ($value =~ /\A((?=.{1,253}\z)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)*[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)\z/) {
        return lc $1;
    }
    return undef;
}

sub _canon_ip {
    my ($value) = @_;
    return undef unless defined $value;

    # Strip surrounding whitespace and untaint only IP-ish input.
    return undef unless $value =~ /\A\s*([0-9A-Fa-f:.]+)\s*\z/;
    $value = $1;

    my $packed = inet_pton(AF_INET, $value);
    return "4:" . unpack("H*", $packed) if defined $packed;

    $packed = inet_pton(AF_INET6, $value);
    return "6:" . unpack("H*", $packed) if defined $packed;

    return undef;
}

sub _load_self {
    return if $self_loaded;

    open my $fh, '<', $SELF_FILE
        or die "cannot read $SELF_FILE: $!";

    while (my $line = <$fh>) {
        $line =~ s/#.*$//;
        $line =~ s/^\s+|\s+$//g;
        next if $line eq '';

        my $ip = _canon_ip($line);
        if (defined $ip) {
            $self_ips{$ip} = 1;
            next;
        }

        my $name = _untaint_domain($line);
        die "invalid gateway identity in $SELF_FILE"
            unless defined $name;

        $self_names{$name} = 1;
    }
    close $fh;

    die "$SELF_FILE contains no gateway identities"
        unless %self_names || %self_ips;

    $self_loaded = 1;
}

sub _dnsdb {
    my ($type, $name) = @_;

    # Both arguments have already been constrained by our own validation.
    # Exim dnsdb uses Exim's resolver and returns all records newline-separated.
    my $query = '${lookup dnsdb{' . $type . '=' . $name . '}{$value}fail}';
    return Exim::expand_string($query);
}

sub _resolve_ips {
    my ($host) = @_;
    my $now = time;

    if (exists $addr_cache{$host} && $addr_cache{$host}{expires} > $now) {
        return $addr_cache{$host}{ips};
    }

    my %ips;

    for my $type ('a', 'aaaa') {
        my $raw = _dnsdb($type, $host);
        next unless defined $raw;

        for my $line (split /\n/, $raw) {
            my $ip = _canon_ip($line);
            $ips{$ip} = 1 if defined $ip;
        }
    }

    my $result = \%ips;
    $addr_cache{$host} = {
        expires => $now + $ADDR_TTL,
        ips     => $result,
    };
    return $result;
}

sub _is_self {
    my ($host) = @_;
    return 1 if $self_names{$host};

    my $ips = _resolve_ips($host);
    for my $ip (keys %$ips) {
        return 1 if $self_ips{$ip};
    }
    return 0;
}

sub _lookup_route {
    my ($domain) = @_;

    my $raw = _dnsdb('mx', $domain);
    return '' unless defined $raw && $raw ne '';

    my @mx;
    for my $line (split /\n/, $raw) {
        # Exim dnsdb MX format is: preference hostname
        next unless $line =~ /\A\s*(\d+)\s+(\S+)\s*\z/;
        my $pref = 0 + $1;
        my $raw_host = $2;

        # RFC 7505 null MX: "0 ."
        return '' if $raw_host eq '.';

        my $host = _untaint_domain($raw_host);
        next unless defined $host;

        push @mx, [$pref, $host];
    }

    return '' unless @mx;

    @mx = sort {
        $a->[0] <=> $b->[0] || $a->[1] cmp $b->[1]
    } @mx;

    my $found_self = 0;
    my @backends;
    my %seen;

    for my $item (@mx) {
        my ($pref, $host) = @$item;
        next if $seen{$host}++;

        if (_is_self($host)) {
            $found_self = 1;
            next;
        }

        push @backends, [$pref, $host];
    }

    # Not one of our guarded domains: decline the router.
    return '' unless $found_self;

    # Guarded but every MX resolves back to this gateway: never loop.
    die "guarded domain $domain has no non-gateway MX backend"
        unless @backends;

    # Keep MX preference order. "byname" makes manualroute use normal
    # resolver/NSS semantics, including /etc/hosts, for backend A/AAAA.
    return join(':', map { $_->[1] } @backends) . ' byname';
}

sub mxroute {
    my ($input_domain) = @_;
    _load_self();

    my $domain = _untaint_domain($input_domain);
    return '' unless defined $domain;

    my $now = time;
    if (exists $route_cache{$domain} && $route_cache{$domain}{expires} > $now) {
        return $route_cache{$domain}{route};
    }

    my $route = _lookup_route($domain);

    $route_cache{$domain} = {
        expires => $now + $ROUTE_TTL,
        route   => $route,
    };

    return $route;
}

1;
