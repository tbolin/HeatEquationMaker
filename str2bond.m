function [ F ] = str2bond(functions, X, Y)
% input_rand funktion för att mata in de kända värdena
%   IN
%	functions cell-array med str-representationer av vilkoren för området
%   X, Y    koordinatmatriser
%   UT 
%   F   logisk matris med vilkor för att en punkt ska anses
%       tillhöra området som ska beräknas 
	functions = ['x>x(1)', 'y>y(1)', 'x<x(end)', 'y<y(end)', functions]; 
		% Ser till att kanterna alltid är ränder,
		% det blir indexeringsfel senare annars
    F = []; % Matrisen där maskerna ska sparas
    for i=1:length(functions)
        f = str2func(['@(x,y)', functions{i}]);
        F = cat(3, F ,f(X,Y) );
    end
	F = all(F, 3);
end