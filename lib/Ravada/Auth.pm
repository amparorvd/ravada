package Ravada::Auth;

use warnings;
use strict;

our $LDAP;

use Ravada::Auth::SQL;

=head1 NAME

Ravada::Auth - Authentication library for Ravada users

=cut

eval { 
    require Ravada::Auth::LDAP; 
};
if ($@) {
    warn $@;
    $LDAP = 0;
}
warn "LDAP loaded=".($LDAP or '<UNDEF>')    if $Ravada::DEBUG;

=head2 init

Initializes the submodules

=cut

sub init {
    my ($config, $db_con) = @_;
    if ($config->{ldap}) {
        eval { 
            Ravada::Auth::LDAP::init($config); 
            $LDAP = 1;
        };
    } else {
        $LDAP = 0;
    }
#    Ravada::Auth::SQL::init($config, $db_con);
}

=head2 login

Tries login in all the submodules

    my $ok = Ravada::Auth::login($name, $pass);

=cut

sub login {
    my ($name, $pass, $quiet) = @_;

    my $login_ok;
    if (!defined $LDAP || $LDAP) {
        eval {
            $login_ok = Ravada::Auth::LDAP->new(name => $name, password => $pass);
        };
        warn $@ if $@ && $LDAP && !$quiet;
        return $login_ok if $login_ok;
    }

    if ($@ =~ /I can't connect/i) {
        $LDAP = 0 if !defined $LDAP;
    }
    return Ravada::Auth::SQL->new(name => $name, password => $pass);
}

=head2 LDAP

Sets or get LDAP support.

    Ravada::Auth::LDAP(0);

    print "LDAP is supported" if Ravada::Auth::LDAP();

=cut

sub LDAP {
    my $value = shift;
    return $LDAP if !defined $value;

    $LDAP = $value;
    return $value;
}
1;
