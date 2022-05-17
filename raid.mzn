% assignment 2
enum WARRIOR;
WARRIOR: dummy;
enum CLAN; 

int: l; % minimum 
int: u; % maximum 
int: m; % limit of hatreds

array[WARRIOR] of int: strength;
array[WARRIOR] of CLAN: clan;

array[CLAN,CLAN] of 0..1: hates;


array[1..u] of var WARRIOR: r;
set of WARRIOR: raid ::output_only = { fix(r[i]) | i in 1..u where fix(r[i]) != dummy };



constraint forall(i in 1..u-1) (r[i]>=r[i+1] + (r[i] != dummy));

constraint sum(i in 1..u)(r[i]!=dummy) >= l;

constraint forall(i in 1..l)(r[i]!=dummy);

constraint sum(i,j in 1..u where i < j)(hates[clan[r[i]],clan[r[j]]]) <= m;


var int: obj = sum(i in 1..u where r[i] != dummy)(strength[r[i]]);


% Ouput
output ["raid = \(raid);\nobj = \(obj);\n"];

solve maximize obj;


