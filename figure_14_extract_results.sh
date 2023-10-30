INPUT=$1

echo
echo "=========================================================="
echo "Extracting data compression results from: $INPUT ..."
echo

echo "DEFLATE Level=1 Static : $(pcregrep -M -A 16 'Data_Plane\n.*\n.*DEFLATE\n.*(.)*STATIC\n.*\n.*\n.*COMPRESS\n.*\n.*1$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"
echo "DEFLATE Level=1 Dynamic: $(pcregrep -M -A 16 'Data_Plane\n.*\n.*DEFLATE\n.*(.)*DYNAMIC\n.*\n.*\n.*COMPRESS\n.*\n.*1$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"
echo "DEFLATE Level=2 Static : $(pcregrep -M -A 16 'Data_Plane\n.*\n.*DEFLATE\n.*(.)*STATIC\n.*\n.*\n.*COMPRESS\n.*\n.*2$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"
echo "DEFLATE Level=2 Dynamic: $(pcregrep -M -A 16 'Data_Plane\n.*\n.*DEFLATE\n.*(.)*DYNAMIC\n.*\n.*\n.*COMPRESS\n.*\n.*2$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"
echo "LZ4     Level=1 8KB    : $(pcregrep -M -A 16 'LZ4\n.*\n.*\n.*\n.*COMPRESS\n.*8192\n.*1$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"
echo "LZ4     Level=1 64KB   : $(pcregrep -M -A 16 'LZ4\n.*\n.*\n.*\n.*COMPRESS\n.*65536\n.*1$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"
echo "LZ4     Level=9 8KB    : $(pcregrep -M -A 16 'LZ4\n.*\n.*\n.*\n.*COMPRESS\n.*8192\n.*9$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"
echo "LZ4     Level=9 64KB   : $(pcregrep -M -A 16 'LZ4\n.*\n.*\n.*\n.*COMPRESS\n.*65536\n.*9$' $INPUT | grep Throughput | awk '{ print $2 }') Mbps"

echo
echo "=========================================================="
