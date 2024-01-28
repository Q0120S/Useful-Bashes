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
