%clear all, close all, clc

% område
n = 49; 		% Upplösningen på området
r_scale = -1:1/n:1;	% Områdets omfattning
[X, Y] = meshgrid(r_scale); % Skapar nxn X- och Y-matriser (så mycket snyggare än den gamla)

area = {'x.^2+y.^2<0.3'};
temp = {'5*x*(x>0.25)', '-2*(x<0.25)', '5*(y>0.25)', '-4*(y<0.25)'};
F = str2bond(area, X, Y);
B = str2rand(temp, X, Y);

Q = @(x, y)300*exp(-(x-y).^2)+3000*exp(-1000*(x).^2);
q = bsxfun(Q, r_scale, r_scale');
% tidssteg
start = 0;
stop = 1;
dt = 0.004;
t_scale = start:dt:stop;
drop = 3;
% fysik
k = 0.4;
dens = 1; % densitet
cap = 2.5; % Värmekapacitet

% Lös steady-state för att hitta utgångslöget
solution = solve_temp_Q(F, B, q, r_scale, k);
% lös
timed = solve_time_change(F, B, 0, solution, r_scale, t_scale, drop, k, dens, cap)









