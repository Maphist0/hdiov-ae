INPUT=$1

echo
echo "=========================================================="
echo "Extracting symmetric crypto (AES256-CBC-HMAC-SHA2-512) results from: $INPUT ..."
echo "Notice: sym results tend to be CPU-bound. Lower CPU frequency may affect results."
echo

echo "Pkt size   64: $(pcregrep -M -A 6 '.*Chaining.*512$\n.*\n.*Data_Plane\n.*64$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"
echo "Pkt size  256: $(pcregrep -M -A 6 '.*Chaining.*512$\n.*\n.*Data_Plane\n.*256$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"
echo "Pkt size 1024: $(pcregrep -M -A 6 '.*Chaining.*512$\n.*\n.*Data_Plane\n.*1024$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"
echo "Pkt size 4096: $(pcregrep -M -A 6 '.*Chaining.*512$\n.*\n.*Data_Plane\n.*4096$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"
echo "Pkt size  mix: $(pcregrep -M -A 6 '.*Chaining.*512$\n.*\n.*Data_Plane\n.*8892B$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"

echo
echo "=========================================================="
