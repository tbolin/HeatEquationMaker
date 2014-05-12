function S=solve_temp_Q(F, B, Q, scale, k)
% Funktion för att ställa upp och beräkna jämviktstemperaturer
%   IN 
%   F       3D-imensionell logisk matris med vilkor för att en punkt ska annses
%           tillhöra området som ska beräknas
%   B       Matris som innehåller de kända värdena utanför beräkningsområdet.
%   Q       Matris som innehåller tillförd värme vid varje punkt.
%   scale   Skalan för diskretiseringen
%   k       Materialets värmeledningsförmåga
%   UT
%   S       Matris med de uträknade inre värden och de kända yttre
    B = B.*(~F);  % Tar bort inre punkter från randmatrisen
    Q = Q.*(F);   % Sätter värmetillskotet till 0 för randpunkter
    k_ind=find(F);      % Index i F sedd som vektor för alla nollskillda element i F.
                    % Härefter reffererat till som k-index
    N=length(k_ind);    % Antalet nollskillda element i F
    F=zeros(size(F)); % Gör om F till en riktigt matris
    F(k_ind)=(1:N)'; % Sätter in k-index på varje 0-skillt elements plats i F 
                 % (kolla på F för att förstå hur det ser ut)
    i=(1:N)';    % Index i F för de element som ska sättas in i koefficientmatrisen A
    A=sparse(i,i,-4);    % Skapar koefficientmatrisen A och sätter in mitt-vikterna (-4) på diagonalen.
    b = zeros(N,1); % Skapar högerledet där randvärdena ska sättas in
    % Sätter in grannarna
    n = length(B);
    h = scale(2)-scale(1); % Steglängden
    for neighbour=[-n -1 +1 +n] % Grannen tv, över, under och th
        [row, foo, col] = find(F(k_ind+neighbour)); % Tar alla grannar som inte är randvärden
        % Varje punkt påverkas av de 4 grannarna
        % om en granne inte är randvärden ska det stå en 1:a på punktens rad
        % i grannens kolonn. 
        % row blir därför k-index för de punkter som har inre punkter som
        % grannar åt det aktuella hållet.
        % foo är kolonn-index i F(k), men eftersin F(k) är en vektor blir det
        % bara 1:or, finns bara för att matlab inte har en fku som ger
        % vektor-index och värde.
        % col är värdena som punkterna i F har, dvs grannens k-index
        b = b - B(k_ind+neighbour); % Ja, det ska vara minus här
        A = A + sparse(row, col, 1, N, N);
    end
    b = b-(h^2/k)*Q(k_ind); % Energitillskottet
    %%% Lös och sätt ut på plotten igen
    x = A\b;
    S = B;
    S(k_ind) = x;