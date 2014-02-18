function [ B ] = str2rand(functions, X, Y)
% input_rand funktion för att mata in de kända värdena
%   IN
%	functions cell-array med str-representationer av vilkoren för området
%   X, Y    koordinatmatriser
%   UT 
%   B	Matris med kända temperaturväden
    B = []; % Matrisen där temperaturerna
    for i=1:length(functions) 
        f = str2func(['@(x,y)', functions{i}]);
        B = cat(3, B ,f(X,Y) );
    end
	B = sum(B, 3);
end