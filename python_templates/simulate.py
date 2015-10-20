'''
Created on 05-Dec-2013

@author: sivananda
'''
import os
import argparse 

parser = argparse.ArgumentParser(description='Simulation script')
parser.add_argument('-i','--input', nargs='*',help = 'Give input file list to be simulated \n Test bench file must be the first argument');
parser.add_argument('-s','--stop_time', nargs=1,help = 'Stop time for simulation');
args = parser.parse_args()
files = args.input
stop_time =  args.stop_time
print files;
print len(files);
analysis_commands = [];
for i in range(0, len(files)):
    analysis_commands.append("ghdl -a --ieee=synopsys -fexplicit "+files[i]);
    process = os.popen(analysis_commands[i]);
    print analysis_commands[i];
    print process.read();
    process.close();

exec_tb = files[0][:-4]
temp = "ghdl -e --ieee=synopsys -fexplicit "+exec_tb
print temp
process = os.popen(temp)
print process.read();
process.close();

temp = "ghdl -r "+exec_tb+" --vcd="+exec_tb+".vcd --stop-time="+stop_time[0];
print temp
process = os.popen(temp)
print process.read()
process.close();

temp = "gtkwave "+exec_tb+".vcd"
print temp
process = os.popen(temp)
print process.read()
process.close();
