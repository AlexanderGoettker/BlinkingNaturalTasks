function vShuffled = ShuffleVector(v)

blockSize = 10000;                    % Größe jedes Blocks

% --------------------------------------------------------------
% 2. Anzahl aller vollen Blöcke
% --------------------------------------------------------------
N      = numel(v);                 % Gesamtlänge
nBlocks = floor(N / blockSize);     % Anzahl ganzer Blöcke (60 000)

% --------------------------------------------------------------
% 3. Vektor in Matrix umformen – jede Spalte ist ein Block
% --------------------------------------------------------------
%  Reshape erzeugt eine `blockSize × nBlocks` Matrix
%  (Jede Spalte = ein 10‑Element‑Block)
blocks = reshape(v(1:nBlocks*blockSize), blockSize, nBlocks);

% --------------------------------------------------------------
% 4. Blöcke zufällig permutieren
% --------------------------------------------------------------
permIdx = randperm(nBlocks);       % Zufällige Permutation der Block‑Indizes
blocks  = blocks(:, permIdx);      % Blöcke neu anordnen

% --------------------------------------------------------------
% 5. Matrix wieder zu Vektor „flatten“
% --------------------------------------------------------------
vShuffled = blocks(:);             % Spalten‑Aufbau (Spalten‑Linker ab)
%   * Alternativ `vShuffled = blocks.'(:);`  → Zeilen‑Aufbau

% --------------------------------------------------------------
% 6. Rest‑Elemente anhängen (falls Länge nicht exakt 10‑fach)
% --------------------------------------------------------------
if nBlocks < ceil(N/blockSize)     % gibt ein Rest‑Element‑Block
    restVec = v(nBlocks*blockSize+1:end);   % die unveränderten Elemente
    vShuffled = [vShuffled; restVec];
end
