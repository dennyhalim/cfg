zmprov gacf | grep zimbraMtaRestriction

zmprov mcf \
zimbraMtaRestriction reject_invalid_helo_hostname \
zimbraMtaRestriction reject_non_fqdn_sender \
zimbraMtaRestriction reject_invalid_hostname  \
zimbraMtaRestriction "reject_rbl_client zen.spamhaus.org" \
zimbraMtaRestriction "reject_rbl_client bl.spamcop.net" \
zimbraMtaRestriction "reject_rbl_client dnsbl.sorbs.net" \
zimbraMtaRestriction "reject_rbl_client cbl.abuseat.org" \
zimbraMtaRestriction "reject_rbl_client dnsbl.njabl.org"

zmprov gacf | grep zimbraMtaRestriction
