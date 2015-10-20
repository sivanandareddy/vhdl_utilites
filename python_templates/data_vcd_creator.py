'''
Created on 02-Jan-2014

@author: sivananda
'''
import os
import math
import csv


def sign (num):
    if num >= 0 :
        return 1;
    else:
        return -1;    
def freq (t):
    F_min = 25e3;
    F_max = 25e3;
    env_width_margin = env_width + 0.2e-3
    F = (F_min - F_max)*t/env_width_margin + F_max;
    return F
def phase(t):
    Phi_min = 0*2*math.pi;
    Phi_max = 0.1*2*math.pi;
    env_width_margin = env_width ;#+ 0.2e-3;
    Phi = (Phi_min - Phi_max)*t/env_width_margin + Phi_max;
    return Phi
#value change dump file location
filename = "/media/STORE/work_space/test_aptana_ws/test/waveform.vcd" 
global env_width;
env_width = 1e-3; #envelope width that is pulse duration of modulator
file_ptr = open(filename,"w");
delta_t = 20e-9;
delay = 200; #delay this is used to delay the first pulse of phase A and accordingly all of them
N = env_width/delta_t; #Total number of pulses.

#making of vcd file#
file_ptr.write("$timescale 20 ns $end\n");
file_ptr.write("$comment this is first attempt $end\n");
read_out = os.popen("date\n");
date = read_out.read()[:-1];
file_ptr.write("$date "+date+" $end\n");
file_ptr.write("$scope module top $end\n");
file_ptr.write("$var real 16 ! phaseA $end\n");
file_ptr.write("$var real 16 @ phaseB $end\n");
file_ptr.write("$var real 16 # phaseC $end\n");
file_ptr.write("$var real 16 $ phaseA_Sh $end\n");
file_ptr.write("$var real 16 % phaseB_Sh $end\n");
file_ptr.write("$var real 16 ^ phaseC_Sh $end\n");
file_ptr.write("$var real 16 & frequency $end\n");
file_ptr.write("$var real 16 * phase $end\n");
file_ptr.write("$upscope $end\n")
file_ptr.write("$enddefinitions $end\n")
phaseA_list = [];
phaseA_list.append(0);
phaseA_prev = math.sin(2*math.pi*freq(0*delta_t)*delta_t*0);
phaseA_sh_list = [];
phaseA_sh_list.append(0);
phaseA_sh_prev = math.sin(2*math.pi*freq(0*delta_t)*delta_t*0 - phase(0*delta_t))
phaseB_list = [];
phaseB_list.append(0);
phaseB_prev = math.sin(2*math.pi*freq(0*delta_t)*delta_t*0 - 120*math.pi/180)
phaseB_sh_list = [];
phaseB_sh_list.append(0);
phaseB_sh_prev = math.sin(2*math.pi*freq(0*delta_t)*delta_t*0 - 120*math.pi/180 - phase(0*delta_t))
phaseC_list = [];
phaseC_list.append(0);
phaseC_prev = math.sin(2*math.pi*freq(0*delta_t)*delta_t*0 - 240*math.pi/180)
phaseC_sh_list = [];
phaseC_sh_list.append(0);
phaseC_sh_prev = math.sin(2*math.pi*freq(0*delta_t)*delta_t*0 - 240*math.pi/180 - phase(0*delta_t))
for t in range(0,int(N)):
    frequency = freq(t*delta_t);
    phase_l = phase(t*delta_t);
    phaseA = math.sin(2*math.pi*freq(t*delta_t)*delta_t*t)
    phaseA_sh = math.sin(2*math.pi*freq(t*delta_t)*delta_t*t - phase(t*delta_t))
    phaseB = math.sin(2*math.pi*freq(t*delta_t)*delta_t*t - 120*math.pi/180)
    phaseB_sh = math.sin(2*math.pi*freq(t*delta_t)*delta_t*t - 120*math.pi/180 - phase(t*delta_t))
    phaseC = math.sin(2*math.pi*freq(t*delta_t)*delta_t*t - 240*math.pi/180)
    phaseC_sh = math.sin(2*math.pi*freq(t*delta_t)*delta_t*t - 240*math.pi/180 - phase(t*delta_t))
    if (sign(phaseA) != sign(phaseA_prev)):
        phaseA_list.append(t - sum(phaseA_list));
    phaseA_prev = phaseA;
    if (sign(phaseA_sh) != sign(phaseA_sh_prev)):
        phaseA_sh_list.append(t - sum(phaseA_sh_list));
    phaseA_sh_prev = phaseA_sh;
    if (sign(phaseB) != sign(phaseB_prev)):
        phaseB_list.append(t - sum(phaseB_list));
    phaseB_prev = phaseB;
    if (sign(phaseB_sh) != sign(phaseB_sh_prev)):
        phaseB_sh_list.append(t - sum(phaseB_sh_list));
    phaseB_sh_prev = phaseB_sh;
    if (sign(phaseC) != sign(phaseC_prev)):
        phaseC_list.append(t - sum(phaseC_list));
    phaseC_prev = phaseC;
    if (sign(phaseC_sh) != sign(phaseC_sh_prev)):
        phaseC_sh_list.append(t - sum(phaseC_sh_list));
    phaseC_sh_prev = phaseC_sh;
#    print (phaseA_list[-1]);
#    print (phaseA_list);
    
    file_ptr.write("#"+str(int(t))+"\n");
    file_ptr.write("r"+str(phaseA)+" !\n")
    file_ptr.write("r"+str(phaseA_sh)+" $\n")
    file_ptr.write("r"+str(phaseB)+" @\n")
    file_ptr.write("r"+str(phaseB_sh)+" %\n")
    file_ptr.write("r"+str(phaseC)+" #\n")
    file_ptr.write("r"+str(phaseC_sh)+" ^\n")
    file_ptr.write("r"+str(frequency)+" &\n")
    file_ptr.write("r"+str(phase_l)+" *\n")
file_ptr.close();
#print len(phaseA_list);
#print len(phaseA_sh_list);
#print len(phaseB_list);
#print len(phaseB_sh_list);
#print len(phaseC_list);
#print len(phaseC_sh_list);
###########making of vcd file is over################

##find the pulse width positive of each pulse ###############
if (sign(phaseA) == 1):
    phaseA_list.append(int(N) - sum(phaseA_list));
if (sign(phaseA_sh) == 1):
    phaseA_sh_list.append(int(N) - sum(phaseA_sh_list));
if (sign(phaseB) == 1):
    phaseB_list.append(int(N) - sum(phaseB_list));
if (sign(phaseB_sh) == 1):
    phaseB_sh_list.append(int(N) - sum(phaseB_sh_list));
if (sign(phaseC) == 1):
    phaseC_list.append(int(N) - sum(phaseC_list));
if (sign(phaseC_sh) == 1):
    phaseC_sh_list.append(int(N) - sum(phaseC_sh_list));
base_addr = 2
no_ch = 6
final_list = [];
env_low_byte = int(env_width/20e-9) & 0xffff;
env_high_byte = (int(env_width/20e-9) >> 16) & 0xffff;
final_list.append([0,env_low_byte]);
final_list.append([1,env_high_byte]);
final_list.append([base_addr,len(phaseA_list)]);
final_list.append([base_addr+1,len(phaseA_sh_list)]);
final_list.append([base_addr+2,len(phaseB_list)]);
final_list.append([base_addr+3,len(phaseB_sh_list)]);
final_list.append([base_addr+4,len(phaseC_list)]);
final_list.append([base_addr+5,len(phaseC_sh_list)]);
max_list_len = min(len(phaseA_list), len(phaseA_sh_list), 
                   len(phaseB_list), len(phaseC_list), 
                   len(phaseB_sh_list), len(phaseC_sh_list));
for index in range(1,max_list_len):
    if index < len(phaseA_list):
        final_list.append([index*6+base_addr, (phaseA_list[index])]);
    else:
        final_list.append([index*6+base_addr, (0xffff)]);
    if index < len(phaseA_sh_list):
        final_list.append([index*6+base_addr+1, (phaseA_sh_list[index])]);
    else:
        final_list.append([index*6+base_addr+1, (0xffff)]);
    if index < len(phaseB_list):
        final_list.append([index*6+base_addr+2, (phaseB_list[index])]);
    else:
        final_list.append([index*6+base_addr+2, (0xffff)]);
    if index < len(phaseB_sh_list):
        final_list.append([index*6+base_addr+3, (phaseB_sh_list[index])]);
    else:
        final_list.append([index*6+base_addr+3, (0xffff)]);
    if index < len(phaseC_list):
        final_list.append([index*6+base_addr+4, (phaseC_list[index])]);
    else:
        final_list.append([index*6+base_addr+4, (0xffff)]);
    if index < len(phaseC_sh_list):
        final_list.append([index*6+base_addr+5, (phaseC_sh_list[index])]);
    else:
        final_list.append([index*6+base_addr+5, (0xffff)]);

base_addr = base_addr + no_ch - 1
########### corrections to final list ################
####make 6
if (final_list[base_addr + 5][1] + 
    final_list[base_addr + 3][1] >= final_list[base_addr + 1][1]):
    final_list[base_addr + 12][1] = final_list[base_addr + 6][1];
    final_list[base_addr + 6][1] = delay;
else:
    final_list[base_addr + 6][1] = final_list[base_addr + 6][1] + delay;
###make 5
final_list[base_addr + 11][1] = final_list[base_addr + 5][1];
final_list[base_addr + 5][1] = delay;
###make 4
if (final_list[base_addr + 2][1] + 
    final_list[base_addr + 3][1] >= final_list[base_addr + 1][1]):
    final_list[base_addr + 10][1] = final_list[base_addr + 4][1];
    final_list[base_addr + 4][1] = delay;
else:
    final_list[base_addr + 4][1] = final_list[base_addr + 4][1] + delay;
###make 3
final_list[base_addr + 3][1] = final_list[base_addr + 3][1] + delay;
###make 2
if final_list[base_addr + 1][1] == final_list[base_addr + 2][1] :
    final_list[base_addr + 2][1] = delay;
else:
    final_list[base_addr + 2][1] = final_list[base_addr + 2][1] + delay;
###make 1
final_list[base_addr + 1][1] = delay;
################################################################################

####correction take difference of 3 from every pulse width######################
for index in range(base_addr,len(final_list)):
    final_list[index][1] = final_list[index][1] - 3;
################################################################################

###corrections for setting the channels with even number of changes#############
base_addr = 2;
for index in range(0,6):
    if ((final_list[base_addr + index][1] % 2) == 1) :
        final_list[base_addr + index][1] = final_list[base_addr + index][1] - 1;
        print (final_list[base_addr + 1][1])
################################################################################
filename = "/media/STORE/work_space/test_aptana_ws/test/test.csv"
with open(filename, 'wb') as test_file:
    csv_writer = csv.writer(test_file)
    csv_writer.writerows(final_list)
#os.system("gtkwave /media/STORE/work_space/test_aptana_ws/test/waveform.vcd");#
print ("completed.....")