%%% Instructions

delete(timerfindall)
clear all;
clc;

% This function returns a 1 if basic internet connectivity

% define the URL for US Naval Observatory Time page
url =java.net.URL('http://tycho.usno.navy.mil/cgi-bin/timer.pl');

% read the URL
link = openStream(url);
parse = java.io.InputStreamReader(link);
snip = java.io.BufferedReader(parse);
if ~isempty(snip)
    
    
    myTimer1 = timer();
    myTimer1.StartFcn = '';
    myTimer1.TimerFcn = 'plotBuoyPositions;';
    myTimer1.Period = 600; % time in seconds
    myTimer1.BusyMode = 'drop';
    myTimer1.ErrorFcn = 'disp(''Error Occurred'')';
    myTimer1.StopFcn = '';
    myTimer1.TasksToExecute = Inf;
    myTimer1.Tag = 'Text_Timer';
    myTimer1.ExecutionMode = 'fixedSpacing';
    
    
    start(myTimer1);
   
else
    disp('PLEASE CHECK INTERNT CONNECTION BEFORE RUNNING THIS FUNCTION!!!!!!!');
end