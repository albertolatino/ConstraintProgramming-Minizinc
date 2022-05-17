int: T; % maximum time allowed;
set of int: TIME = 1..T;

int: E; % weight of elephant in STONES;
set of int: STONE = 0..E;

int: G; % number of guards
set of int: GUARD = 1..G;
array[GUARD] of STONE: easy;
array[GUARD] of STONE: hard;
array[GUARD] of TIME: tired;

GUARD: p; % maximum people on pier;
GUARD: b; % maximum people on boat;

set of int: ACT = -1..E; % -1 = goto bank, 0 = wait, > 0 carry stones
int: wait = 0;
int: to_bank = -1;
array[GUARD,TIME] of var ACT: act;        % action at time t
var TIME: end;                            % end time;
set of int: TIME0 = 0..T;
%%CHECK TIME0

array[TIME] of var STONE: move_stone;
enum POS = { Bank, Boat};
array[GUARD,TIME0] of var POS: pos;
array[POS] of POS: opp = {Boat, Bank};


%%All guards are on the bank at the beginning
constraint forall(g in GUARD) (pos[g,0] = Bank);

%%Guard movements
predicate guard(var POS: now, var POS: next, var ACT: act) = 

          if act == wait then
          next = now
          
          elseif (now == Bank /\ act >0) then
          next = Boat
          
          elseif (now == Boat /\ act = -1) then
          next = Bank
          
          else
          true
          
          endif;
 
                                             
constraint forall(t in TIME ,g in GUARD) (guard(pos[g,t-1], pos[g,t], act[g,t]));  
%Constraints to complete the relation between the movements allowed 
constraint forall(t in TIME, g in GUARD) (act[g,t] = -1 -> (pos[g,t-1] = Boat));
constraint forall(t in TIME, g in GUARD) (act[g,t] > 0 -> (pos[g,t-1] = Bank));

        
%%Tells whether a guard is moving or not
predicate move (var TIME: t, var GUARD: g) = (act[g,t] != wait); 

%%Guards cannot bring more than hard
constraint forall (t in TIME, g in GUARD) (act[g,t] <= hard[g]);

%%Maximum people on pier
constraint forall (t in TIME) (sum(g in GUARD) (move(t,g)) <= p);

%%Maximum people on boat
constraint forall(t in TIME)(sum(g in GUARD)(pos[g,t] = Boat) <= b);
                                                                                               
%%The stone  moved on the boat are the sum of all the stones brought by guards
constraint forall (t in TIME) (move_stone[t] = sum(g in GUARD where act[g,t] > 0) (act[g,t]));

%%Time constraint of stones on the boat
constraint sum(t in TIME, g in GUARD where act[g,t]>0) (act[g,t]) = E;

%%Tells whether a guard is tired at moment t
constraint forall(t,t1 in TIME, g in GUARD where t1>t /\ t1<=(tired[g]+t))((act[g,t]>easy[g]) -> act[g,t1] <= 0);

%%Guards move in the same direction
constraint forall(t in TIME, g,g1 in GUARD) ((act[g,t]*act[g1,t])>=0); 

%%After the end every one stays in its own position
constraint forall(t in TIME, g in GUARD)(t > end -> act[g,t] = wait);

solve minimize end;

          