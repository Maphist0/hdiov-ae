INPUT=$1

echo
echo "=========================================================="
echo "Extracting asymmetric crypto results from: $INPUT ..."
echo

echo "RSA CRT Decrypt 1K: $(pcregrep -M -A 6 'RSA.*\n.*1024$' $INPUT | grep Operations | awk '{ print $4 }') Mbps"
echo "RSA CRT Decrypt 2K: $(pcregrep -M -A 6 'RSA.*\n.*2048$' $INPUT | grep Operations | awk '{ print $4 }') Mbps"
echo "RSA CRT Decrypt 4K: $(pcregrep -M -A 6 'RSA.*\n.*4096$' $INPUT | grep Operations | awk '{ print $4 }') Mbps"
echo "DH Phase-2      2K: $(pcregrep -M -A 6 'DIFFIE-HELLMAN.*\n.*2048$' $INPUT | grep Operations | awk '{ print $4 }') Mbps"
echo "DH Phase-2      4K: $(pcregrep -M -A 6 'DIFFIE-HELLMAN.*\n.*4096$' $INPUT | grep Operations | awk '{ print $4 }') Mbps"
echo "DSA             1K: $(pcregrep -M -A 8 'DSA.*\n.*1024$' $INPUT | grep Operations | awk '{ print $4 }') Mbps"
echo "ECDSA          384: $(pcregrep -M -A 8 'ECDSA.*\n.*384$' $INPUT | grep Operations | awk '{ print $4 }') Mbps"

echo
echo "=========================================================="
