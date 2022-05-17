% Beauty Trap
% Perform the most seductive dance

enum LEGS = {spin, leap, waltz, curtsey, prep, stand};
enum ARMS = {beckon, out, up, wrapped, neutral};
enum FACE = {smile, wink, batt, think, glow, blank};

int: maxlen;
set of int: STEP = 1..maxlen;
array[LEGS] of int: maxlegs;
array[ARMS] of int: maxarms;
array[FACE] of int: maxface;
constraint assert(maxlegs[stand] >= maxlen, "maxlegs[stand] smaller than maxlen");
constraint assert(maxarms[neutral] >= maxlen, "maxarms[neutral] smaller than maxlen");
constraint assert(maxface[blank] >= maxlen, "maxface[blank] smaller than maxlen");
array[LEGS,ARMS] of int: dance_value;
array[ARMS,FACE] of int: entice_value;
constraint assert(dance_value[stand,neutral] = 0, "incorrect dance_value array");
constraint assert(entice_value[neutral,blank] = 0, "incorrect entice_value array");
int: boredom; % how bored each step make the viewer

var STEP: len;
array[STEP] of var LEGS: legs;
array[STEP] of var ARMS: arms;
array[STEP] of var FACE: face;


%%CONSTRAINTS ON THE SEQUENCE OF LEGS MOVES

include "global_cardinality_low_up_closed.mzn";
include "regular.mzn";


constraint regular(legs, 7, 6, leg_trans, 1, {7});
constraint regular(arms, 6, 5, arm_trans, 1, {6});
constraint regular(face, 7, 6, face_trans, 1, {7});

         
array[1..7, LEGS] of 0..7: leg_trans =
                          [|2,0,4,5,6,7 %Initial
                           |0,0,0,5,6,7 %Spin
                           |2,0,4,0,0,7 %Leap
                           |2,0,4,0,6,7 %Waltz
                           |2,0,4,5,0,7 %Curtsey
                           |2,3,4,5,6,7 %Prep
                           |2,0,4,5,6,7 %Stand
                           |];

array[1..6, ARMS] of 0..6: arm_trans =
                          [|0,3,4,5,6 %Initial
                           |0,3,4,5,6 %Beckon
                           |2,0,4,0,6 %Out
                           |2,3,0,0,6 %Up
                           |0,3,4,0,6 %Wrapped
                           |0,3,4,5,6 %Neutral
                           |];

                                              
array[1..7, FACE] of 0..7: face_trans =
                          [|2,3,4,5,6,7 %Initial
                           |2,3,4,0,6,7 %Smile
                           |2,3,4,5,6,7 %Wink
                           |2,3,4,0,6,7 %Batt
                           |2,3,4,5,6,7 %Think
                           |2,3,4,5,6,7 %Glow
                           |2,3,4,5,6,7 %Blank
                           |]; 
                       
                           
%%Constraint on maximum number of Waltz in a row 
constraint forall(i in 1..len-3) ((legs[i]=waltz /\ legs[i+1]=waltz /\ legs[i+2]=waltz) -> legs[i+3] != waltz); 
%%Constraint on more than 3 faces 
constraint forall(i in 1..len-2)((face[i]=face[i+1] /\ face[i+1]= face[i+2]) -> face[i]=blank);

%%ARMS CONSTRAINT NOT NEEDED

%%Constraint on stand between Waltz and Cursey
constraint forall(i,j in 1..len where i < j)((legs[i]=waltz /\ legs[j]=curtsey)-> exists(z in i+1..j-1)(legs[z]=stand));

%%Constraint on the end of the dance
constraint(forall(i in len+1..maxlen) (legs[i] = stand /\ arms[i] = neutral /\ face[i] = blank));

%%Constraints on number of times of moves
constraint(global_cardinality_low_up_closed(legs, LEGS, [0 | i in LEGS], maxlegs));
constraint(global_cardinality_low_up_closed(arms, ARMS, [0 | i in ARMS], maxarms));
constraint(global_cardinality_low_up_closed(face, FACE, [0 | i in FACE], maxface));

%%Objective function
var int: seductive_power = sum(i in 1..len)(dance_value[legs[i],arms[i]] + entice_value[arms[i],face[i]]) - (boredom * len);

%%Output
output ["len = ", show(len), ";\n" ++
        "legs = ", show(legs), ";\n" ++
        "arms = ", show(arms), ";\n" ++
        "face = ", show(face), ";\n" ++
        "obj = ", show(seductive_power),";"];

solve maximize seductive_power;


        
                                                               