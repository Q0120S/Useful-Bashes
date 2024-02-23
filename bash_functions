# Get BugBounty Platform Domains that use specific servers
shodan_service_counter() {
	HACKERONE=$(curl -s https://raw.githubusercontent.com/Osb0rn3/bugbounty-targets/main/programs/hackerone.json | jq -r '.[].relationships.structured_scopes.data[].attributes | select(.eligible_for_submission == true) | select(.asset_type == "WILDCARD") | .asset_identifier' | unfurl format %d | grep -E "^\*" | sed -e 's/^\*//' -e 's/^\.//' | tr '[:upper:]' '[:lower:]' | grep -v "*" | sort -u)
	BUGCROWD=$(curl -s https://raw.githubusercontent.com/Osb0rn3/bugbounty-targets/main/programs/bugcrowd.json | jq -r '.[].target_groups[] | select(.in_scope == true) | .targets[] | (.name, .uri)' | unfurl format %d | grep -E "^\*" | sed -e 's/^\*//' -e 's/^\.//' | tr '[:upper:]' '[:lower:]' | grep -v "*" | sort -u)
	INTIGRITI=$(curl -s https://raw.githubusercontent.com/Osb0rn3/bugbounty-targets/main/programs/intigriti.json | jq -r '.[] | select(.domains != null) | .domains[] | select(.endpoint != null) | .endpoint' | unfurl format %d | grep "^\*" | sed -e 's/^\*//' -e 's/^\.//' | tr '[:upper:]' '[:lower:]' | grep -v "*" | sort -u)
	YESWEHACK=$(curl -s https://raw.githubusercontent.com/Osb0rn3/bugbounty-targets/main/programs/yeswehack.json | jq -r '.[].scopes[].scope' | unfurl format %d | grep "^\*" | sed -e 's/^\*//' -e 's/^\.//' | tr '[:upper:]' '[:lower:]' | grep -v "*" | sort -u)
	BUGBOUNTYTARGETES_DOMAINS=$(curl -s https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/domains.txt | unfurl format %r.%t | sort -u)
	BUGBOUNTYTARGETES_WILDCARDS=$(curl -s https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/wildcards.txt | sed -e 's/^\*//' -e 's/^\.//' | sort -u)
	for domain in $(echo $HACKERONE $BUGCROWD $INTIGRITI $YESWEHACK $BUGBOUNTYTARGETES_DOMAINS $BUGBOUNTYTARGETES_WILDCARDS | sed -e 's/^\*//' -e 's/^\.//' | grep -v "^-" | sort -u); do count=$(shodan count Server: $1 hostname:"$domain"); echo "${domain}: ${count}" ; done
}

# Get ASNs & CIDRs of a Company from bgp.he.net 
get_asn_cidrs_bgphe () {
        if [ $# -gt 0 ]
        then
                text=$(echo $@ | sed 's/ /+/g') 
                curl -s "https://bgp.he.net/search?search%5Bsearch%5D=$text&commit=Search" -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:108.0) Gecko/20100101 Firefox/108.0" | pup 'tr json{}' | jq -r '.[] | select(.children[0].children[0].text // "" != "") | { (if (.children[0].children[0].text // "") | startswith("AS") then "ASN" else "CIDR" end): (.children[0].children[0].text // ""), "Description": (.children[2].text // "") }'
        else
                while read line
                do
                        text=$(echo $line | sed 's/ /+/g') 
                        curl -s "https://bgp.he.net/search?search%5Bsearch%5D=$text&commit=Search" -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:108.0) Gecko/20100101 Firefox/108.0" | pup 'tr json{}' | jq -r '.[] | select(.children[0].children[0].text // "" != "") | { (if (.children[0].children[0].text // "") | startswith("AS") then "ASN" else "CIDR" end): (.children[0].children[0].text // ""), "Description": (.children[2].text // "") }'
                done
        fi
}
