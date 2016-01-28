function [theta,mact,mlength]=modelStateFromMotFile()
lineFromMotFile=[...
     20.00000000	      8.73958934	    -10.76116653	     -0.00011672	     -0.01028743	      0.01000000	      0.13947095	      0.01000000	      0.06770193	      0.01000000	      0.06275515	      0.01000000	      0.14418176	      0.01000000	      0.14867898	      0.01000000	      0.08615971	      0.01000000	      0.15694343	      0.01000000	      0.11609072...
];


theta=lineFromMotFile(2:3)/180*pi;

mact=lineFromMotFile(6:2:end);
mlength=lineFromMotFile(7:2:end);