function S=solve_temp(G, B)
% Funktion för att ställa upp och beräkna jämviktstemperaturer
%   IN 
%   F   3D-imensionell logisk matris med vilkor för att en punkt ska annses
%       tillhöra området som ska beräknas
%   B   Matris som innehåller de kända värdena utanför beräkningsområdet.
%   UT
%   S   Matris med de uträknade inre värden och de kända yttre
    B = B.*(~G);  % Tar bort inre punkter från randmatrisen

    k=find(G);      % Index i G sedd som vektor för alla nollskillda element i G.
                    % Härefter reffererat till som k-index
    N=length(k);    % Antalet nollskillda element i G
    G=zeros(size(G)); % Gör om G till en riktigt matris
    G(k)=(1:N)'; % Sätter in k-index på varje 0-skillt elements plats i G 
                 % (kolla på G för att förstå hur det ser ut)
    i=(1:N)';    % Index i G för de element som ska sättas in i koefficientmatrisen A
    A=sparse(i,i,-4);    % Skapar koefficientmatrisen A och sätter in mitt-vikterna (-4) på diagonalen.
    b = zeros(N,1); % Skapar högerledet där randvärdena ska sättas in
    % Sätter in grannarna
    n = length(B);
    for neighbour=[-n -1 +1 +n] % Grannen tv, över, under och th
        [row, foo, col] = find(G(k+neighbour)); % Tar alla grannar som inte är randvärden
        % Varje punkt påverkas av de 4 grannarna
        % om en granne inte är randvärden ska det stå en 1:a på punktens rad
        % i grannens kolonn. 
        % row blir därför k-index för de punkter som har inre punkter som
        % grannar åt det aktuella hållet.
        % foo är kolonn-index i G(k), men eftersin G(k) är en vektor blir det
        % bara 1:or, finns bara för att matlab inte har en fku som ger
        % vektor-index och värde.
        % col är värdena som punkterna i G har, dvs grannens k-index
        b = b - B(k+neighbour); % Ja, det ska vara minus här
        A = A + sparse(row, col, 1, N, N);
    end
    %%% Lös och sätt ut på plotten igen
    x = A\b;
    S = B;
    S(k) = x;