int: n; % number of court members
set of int: COURT = 1..n;
int: emperor = 1;
array[COURT] of int: rank;
array[COURT] of int: ability;

int: m; % number of horses
set of int: HORSE = 1..m;
array[HORSE] of int: beauty;
array[HORSE] of int: speed;

array[COURT,HORSE] of int: enjoy;

include "alldifferent_except_0.mzn";

array[COURT] of var HORSE union {0}: horse;%map a horse to each court member

array[HORSE] of var COURT union {0}: horsecourt;% map a court member to each horse

constraint (alldifferent_except_0(horse));
constraint (alldifferent_except_0(horsecourt));

%%Contraint between two models
constraint forall(i in COURT, j in HORSE)(horse[i]=j <-> horsecourt[j]=i);


%%if more court members, each horse must be used
constraint (n > m) -> forall(i in 1..m) (horsecourt[i] > 0);

%%if more horeses, each court member must ride
constraint (n <= m) -> forall(i in 1..n) (horse[i] > 0);


%%the emperor must enjoy the day more than anyone else 
constraint forall(i in 2..n where horse[i] != 0)(enjoy[i,horse[i]] < enjoy[emperor,horse[emperor]]);

%%Higher rank constraint
constraint forall (i, j in 1..n where rank[i] > rank[j]) (beauty[horse[i]] >= beauty[horse[j]] \/ horse[j] = 0 \/ (horse[i] = 0  /\ horse[j] = 0));


%%non negative enjoy 
constraint forall(i in 1..n where horse[i] != 0) (enjoy[i,horse[i]] >= 0);

%%define number of violations of last constraint
var int: violations = sum(i, j in 1..m where speed[i] > speed[j]) (not(ability[horsecourt[i]] >= ability[horsecourt[j]]
\/ horsecourt[i] = 0 \/ (horsecourt[i] = 0 /\ horsecourt[j] = 0 )));

%%Objective
var int: obj = sum(i in 1..n where horse[i] != 0) (enjoy[i,horse[i]]) - 100 * violations;

%Solve
output ["horse = \(horse);\nobj = \(obj);"];

solve maximize obj;



