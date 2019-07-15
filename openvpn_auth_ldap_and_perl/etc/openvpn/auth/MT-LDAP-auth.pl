#!/usr/bin/perl

use Net::LDAP;
use Authen::Simple::ActiveDirectory;


$USER=$ENV{'username'};
$PASS=$ENV{'password'};
$LDAPSERVER='ldap://XXXXX.local'; #ENDERECO DE DOMINIO
$DOMAIN='XXXXX.local';   #DOMINIO
$VPNGROUPNAME='g_VPN';   #GRUNO VPN

$ldap = Net::LDAP->new( $LDAPSERVER ) or die "$@";
#$mesg = $ldap->bind( "$USER@$DOMAIN",password => "$PASS");
$mesg = $ldap->bind("cn=u_vpn,ou=vpn,ou=servicosti,ou=XXXXX,dc=XXXXX,dc=local",password=>"XXXX_PASS"); #CONEXAO LDAP
$ad = Authen::Simple::ActiveDirectory->new( host => "$DOMAIN", principal => "$DOMAIN", ); 

#print "Username: $USER\n";
#print "Passwod.: $PASS\n";

if ($mesg->code) {
	print "Auth ERROR\n";
	die $mesg->error;
	exit 1;
   } else {
	# Get currently logged in user
	my $userDN = GetDNByID($ldap, $USER);
	print "User DN: $userDN\n";

	# Quick check if user is a member of a group
	#print "User is a member of 'vpnUsers': ", IsMemberOf($ldap, $userDN, GetDNByID($ldap, 'vpnUsers')) ? 'True' : 'False', "n";
	if (IsMemberOf($ldap, $userDN, GetDNByID($ldap, $VPNGROUPNAME)))
	{
    		print "USUARIO NO GRUPO - ";

    		$ldap->unbind();

		if ($ad->authenticate( $USER, $PASS)) 
		{
       			print "AUTH OK\n";
       			exit 0;
            	} else {
        		print "AUTH NOK\n";
                	exit 1;
                }
	} else {
    		print "USUARIO FORA DO GRUPO\n ";
    		$ldap->unbind();
    		exit 1;
	}
} 

# =====================================
# Token query routines
# =====================================
# Is DN a member of security group?
# Usage: <bool> = IsMemberOf(<DN of object>, <DN of group>)
sub IsMemberOf($$$) {
my ($ldap, $objectDN, $groupDN) = @_;
return if ($groupDN eq "");

my $groupSid = GetSidByDN($ldap, $groupDN);
return if ($groupSid eq "");

my @matches = grep { $_ eq $groupSid } GetTokenGroups($ldap, $objectDN);

@matches > 0;
}

# Gets tokenGroups attribute from the provided DN
# Usage: <Array of tokens> = GetTokenGroups(<LDAP ref>, <DN of object>)
sub GetTokenGroups($$) {
my ($ldap, $objectDN) = @_;

my $results = $ldap->search(
base => $objectDN,
scope => 'base',
filter => '(objectCategory=*)',
attrs => ['tokenGroups']
);

if ($results->count) {
return $results->entry(0)->get_value('tokenGroups');
}
}

# =====================================
# Query helper routines
# =====================================

# Get object's SID by DN
# Usage: <SID> = GetSidByDN(<LDAP ref>, <DN>)
sub GetSidByDN($$) {
my ($ldap, $objectDN) = @_;

my $results = $ldap->search(
base => $objectDN,
scope => 'base',
filter => '(objectCategory=*)',
attrs => ['objectSid']
);

if ($results->count) {
return $results->entry(0)->get_value('objectSid');
}
}

# Get DN by sAMAccountName
# Usage: <DN> = GetDNByID(<LDAP ref>, <ID>)
sub GetDNByID($$) {
my ($ldap, $ID) = @_;

my $results = $ldap->search(
base => GetRootDN($ldap),
filter => "(sAMAccountName=$ID)",
attrs => ['distinguishedName']
);

if ($results->count) {
return $results->entry(0)->get_value('distinguishedName');
}
}

# Get sAMAccountName by object's SID
# Usage: <ID> = GetIDBySid(<LDAP ref>, <SID>)
sub GetIDBySid($$) {
my ($ldap, $objectSid) = @_;

my $results = $ldap->search(
base => '<SID=' . unpack('H*', $objectSid) . '>',
scope => 'base',
filter => '(objectCategory=*)',
attrs => ['sAMAccountName']
);

if ($results->count) {
return $results->entry(0)->get_value('sAMAccountName');
}
}

# =====================================
# LDAP routines
# =====================================

# Get Root DN of logged in domain (e.g. DC=yourdomain,DC=com)
# Usage: <DN> = GetRootDN(<LDAP ref>)
sub GetRootDN($) {
my ($ldap) = @_;
($ldap->root_dse->get_value('namingContexts'))[0];
}
