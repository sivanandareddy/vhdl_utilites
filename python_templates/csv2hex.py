'''
Created on 19-Dec-2013

@author: sivananda
'''
import csv
filename = "test.csv";
hexfile = "rom_data.hex";
hexfp = open(hexfile,'w');
fp = open(filename,'r');
csv_data = csv.reader(fp,delimiter = ',')
csv_list = list(csv_data);
index = 0;
index_max = len(csv_list);
#index_max = 32
data_buf = range(0,16)
start_code = ':';
byte_count = 16;
addr = 0;
record_type = 0;
end_record = ":00000001FF";
while (index <= index_max):
    for i in range(0,8):
        if (index >= index_max):
            data_buf[2*i] = 0;
            data_buf[2*i+1] = 0;
            index = index + 1;
        else:
            ##############Big Endian Format###############################
            #data_buf[2*i] = ((int(csv_list[index][1])) >> 8) & 0xff;
            #data_buf[2*i+1] = ((int(csv_list[index][1]))) & 0xff;
			##############################################################
			#############Little Endian Format#############################
			data_buf[2*i+1] = ((int(csv_list[index][1])) >> 8) & 0xff;
            data_buf[2*i] = ((int(csv_list[index][1]))) & 0xff;
			##############################################################            
index = index + 1;
    data_str = "";
    for i in range(0,16):
        data_str = data_str + "{:02x}".format(data_buf[i]);
    check_sum = 0;
    for i in range(0,16):
        check_sum = check_sum + data_buf[i];
    check_sum = check_sum + byte_count + (addr & 0xff) + ((addr >> 8) & 0xff) + record_type;
    check_sum = (-1*check_sum) & 0xff;
    #check_sum = ~((check_sum) & 0xff);
    #check_sum = check_sum + 1;  
    buf = "";
    buf = buf + start_code;
    buf = buf + "{:02x}".format(byte_count);
    buf = buf + "{:04x}".format(addr);
    buf = buf + "{:02x}".format(record_type);
    buf = buf + data_str;
    buf = buf + "{:02x}".format(check_sum & 0xff);
    print buf.upper();
    hexfp.write(buf.upper()+'\n');
    addr = addr + 16;
print end_record;
hexfp.write(end_record)
