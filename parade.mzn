int: n;  % number of soldiers
set of int: SOLDIER = 1..n;
set of int: POS = 1..n;
array[SOLDIER] of int: height;
int: cols;    % number of columns of soldiers
int: delta;   % height delta allowed

array[POS] of var SOLDIER: soldier;
array[SOLDIER] of var POS: pos; % position of each soldier

%%Array indicatind the sequence of differences in the parade
array[POS] of var int: paraded_heights;

constraint forall(p in 2..n) (paraded_heights[p] = height[soldier[p]]-height[soldier[p-1]]);

%%Position of each soldier
constraint forall(p in POS, s in SOLDIER)(pos[s] = p <-> soldier[p] = s);

%%Sequence of soldiers in parade
constraint forall(i,j in POS where i<j /\ i>=2)(((i-1)mod(cols)==(j-1)mod(cols))
 ->(pos[i]<pos[j]));


%%The capitain is the first
constraint pos[1] = 1;
constraint soldier[1] = 1;

%%Cannot have the same soldier in two different positions
include "alldifferent.mzn";
constraint alldifferent(soldier);
constraint alldifferent(pos);

%%Happiness is equal to the moment when I reach height difference greater than delta
var int: obj;

constraint forall(j in POS where j>1 /\ j<obj)(paraded_heights[j]<=delta);

constraint exists(i in POS where i>1) (obj = i /\ paraded_heights[i]>delta);

output ["pos=\(pos);\n",
        "obj=\(obj);\n"];
       
%ann: varsel= input_order;
%ann: varsel= first_fail;
ann: varsel= smallest;
%ann: varsel= largest;

ann: valsel = indomain_min;
% ann: valsel = indomain_max;
% ann: valsel = indomain_median;
%ann: valsel = indomain_random;

% search
solve :: int_search(pos, varsel, valsel) maximize obj;


