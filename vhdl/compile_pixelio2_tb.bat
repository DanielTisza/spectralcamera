
ghdl -a -v pixelio2_tb.vhd

ghdl -e -v pixelio2_tb

ghdl -r pixelio2_tb --vcd=out.vcd

C:\tldati\zyboz7\gtkwave\gtkwave\bin\gtkwave out.vcd

pause